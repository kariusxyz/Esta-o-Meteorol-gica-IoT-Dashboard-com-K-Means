function buscarDados() {
    fetch('/api/dados')
        .then(response => response.json())
        .then(data => {
            if (data.erro) {
                console.error(data.erro);
                return;
            }

            // Atualiza o Gráfico
            const imgGrafico = document.getElementById('grafico-kmeans');
            const loadingGrafico = document.getElementById('loading-grafico');
            imgGrafico.src = 'data:image/png;base64,' + data.grafico;
            imgGrafico.style.display = 'block';
            loadingGrafico.style.display = 'none';

            // Atualiza a Tabela
            const corpoTabela = document.getElementById('tabela-corpo');
            corpoTabela.innerHTML = ''; 

            data.tabela.forEach(linha => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${linha.Time}</td>
                    <td>${linha.Temperature}</td>
                    <td>${linha.Humidity}</td>
                    <td>${linha.Light}</td>
                `;
                corpoTabela.appendChild(tr);
            });
        })
        .catch(error => console.error('Erro ao buscar dados:', error));
}

// Quando a página carregar, busca imediatamente e depois repete a cada 10 segundos (10000 ms)
document.addEventListener("DOMContentLoaded", function() {
    buscarDados();
    setInterval(buscarDados, 10000);
});