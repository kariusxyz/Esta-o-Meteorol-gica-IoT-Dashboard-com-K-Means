# 🌤️ Estação Meteorológica IoT & Dashboard com K-Means

Um projeto de Internet das Coisas (IoT) de ponta a ponta que coleta dados climáticos (temperatura, umidade e luminosidade) através de um **ESP32**, armazena em tempo real no **Firebase** e exibe as informações num Dashboard Web. O diferencial do projeto é a utilização do algoritmo de Machine Learning **K-Means** (via Python/Flask) para agrupar e classificar automaticamente os perfis climáticos do ambiente.

## ✨ Funcionalidades
- **Coleta Contínua:** Leitura de sensores a cada 10 segundos.
- **Upload para a Nuvem:** Comunicação direta via API REST com o Firebase Realtime Database.
- **Prevenção de Falhas no Boot:** Estrutura de hardware mapeada para evitar pinos de *strapping* (como o GPIO2), garantindo reinicializações perfeitas e sem o erro `0xb`.
- **Análise Inteligente:** Backend em Python processa a base de dados aplicando padronização (StandardScaler) e clusterização (K-Means) para descobrir padrões entre temperatura e umidade.
- **Dashboard em Tempo Real:** Interface web atualizada de forma assíncrona (JavaScript Fetch API) a cada 10 segundos, sem necessidade de *refresh* na página.

## 🛠️ Tecnologias Utilizadas
**Hardware:**
- Placa ESP32 (NodeMCU)
- Sensor de Temperatura e Umidade DHT11
- Sensor de Luminosidade LDR (Módulo 4 Pinos LM393 com saída Analógica)

**Software e Linguagens:**
- **C++ (Arduino IDE):** Programação do microcontrolador e requisições HTTP.
- **Firebase:** Banco de Dados NoSQL em tempo real (JSON).
- **Python (Flask):** Servidor backend, integração de dados e envio de API.
- **Bibliotecas Python:** `pandas`, `scikit-learn` (K-Means), `matplotlib` e `seaborn`.
- **Frontend:** HTML5, CSS3 e Vanilla JavaScript.

## 🔌 Esquema de Ligação (Wiring)

Para evitar interferências durante o *boot* da placa e garantir a leitura analógica correta, os sensores foram conectados aos pinos seguros do ESP32:

| Componente | Pino do Sensor | Pino ESP32 | Notas |
| :--- | :--- | :--- | :--- |
| **DHT11** | VCC / + | 3V3 | Energia |
| **DHT11** | GND / - | GND | Terra |
| **DHT11** | Data / Out | **D4 (GPIO4)** | Pino seguro, não interfere no boot. |
| **LDR (LM393)** | VCC | 3V3 | Energia |
| **LDR (LM393)** | GND | GND | Terra |
| **LDR (LM393)** | **AO** (Analog Out) | **VP (GPIO36)** | Permite leitura gradual (0-4095). |

*(Nota: O pino DO do sensor LDR foi ignorado para evitar leituras estritamente digitais de 0 ou 100).*

## 📁 Estrutura do Projeto

```text
/
├── esp32_codigo_fonte/
│   └── estacao_firebase.ino   # Código C++ para gravar no Arduino IDE
├── dashboard_web/
│   ├── app.py                 # Backend em Flask (Machine Learning)
│   ├── static/
│   │   ├── style.css          # Estilização visual do dashboard
│   │   └── script.js          # Automação de atualização (10s)
│   └── templates/
│       └── index.html         # Estrutura da página Web
└── README.md
