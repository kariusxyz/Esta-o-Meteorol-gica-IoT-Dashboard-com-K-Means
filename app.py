from flask import Flask, render_template, jsonify
import requests
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import io
import base64

# Impede o Matplotlib de tentar abrir janelas no servidor web
matplotlib.use('Agg')

app = Flask(__name__)

# URL do seu Firebase
FIREBASE_URL = "https://estacao-esp32-default-rtdb.firebaseio.com/sensores.json"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/dados')
def api_dados():
    # 1. Puxar os dados reais do Firebase
    resposta = requests.get(FIREBASE_URL)
    dados_json = resposta.json()
    
    # 2. Converter o JSON para Pandas DataFrame
    registros = [valor for chave, valor in dados_json.items() if valor is not None]
    df = pd.DataFrame(registros)
    
    # Garantir que as colunas existem para evitar erros iniciais
    if df.empty or 'Temperature' not in df.columns:
        return jsonify({"erro": "Nenhum dado válido encontrado no Firebase."})

    # 3. Preparar dados para o K-Means (Temperatura e Umidade)
    X = df[['Temperature', 'Humidity']].dropna()
    
    # Padronizar (do seu código original)
    padronizador = StandardScaler()
    X_padronizado = padronizador.fit_transform(X)
    
    # 4. Criar o Modelo (Fixado em k=3 para carregamento rápido na web)
    modelo_final = KMeans(n_clusters=3, random_state=42, n_init=10)
    df.loc[X.index, 'Cluster'] = modelo_final.fit_predict(X_padronizado) + 1
    
    # 5. Gerar o Gráfico de Dispersão (Seaborn)
    plt.figure(figsize=(8, 5))
    sns.scatterplot(
        data=df, 
        x="Temperature", 
        y="Humidity", 
        hue="Cluster", 
        palette="tab10", 
        s=100
    )
    plt.title("Segmentação Climática (K-Means)")
    plt.xlabel("Temperatura (°C)")
    plt.ylabel("Umidade (%)")
    plt.grid(alpha=0.3)
    plt.tight_layout()
    
    # Converter o gráfico para uma imagem Base64 (sem salvar arquivo físico)
    img_buffer = io.BytesIO()
    plt.savefig(img_buffer, format='png')
    img_buffer.seek(0)
    grafico_base64 = base64.b64encode(img_buffer.getvalue()).decode('utf8')
    plt.close()
    
    # 6. Preparar a tabela para o Frontend (últimos 15 registros)
    # Selecionar apenas as colunas que importam, limpando dados vazios
    df_tabela = df[['Time', 'Temperature', 'Humidity', 'Light']].tail(15).fillna(0)
    tabela_json = df_tabela.to_dict(orient='records')
    
    # Retornar pacote completo para o JavaScript
    return jsonify({
        'tabela': tabela_json,
        'grafico': grafico_base64
    })

if __name__ == '__main__':
    app.run(debug=True)