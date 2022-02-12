# Bolhas no mercado de petróleo (Crude Oil 2000 - 2021)

Projeto desenvolvido na disciplina 'Derivatives', ministrada pelo prof. Dr Cézar Cruz no 1° semestre de 2021 no curso de Economia (UFSCar Sorocaba).

Dentro da literatura em Economia Financeira, um dos temas mais recorrentes é a presença de bolhas em ativos, se elas existem (HMF) e como medí-las.

A metodologia utilizada no projeto consiste em realizar o teste de raíz unitária com janela móvel na série alvo. Em resumo, a utilização da janela móvel se faz nessário para que um mês/semana/qualquer 'timeframe' de descolamento de preços não fosse o suficiente para caracterizar uma bolha.

Dentro do teste de raíz unitária buscamos verificar quando há movimentos explosivos na série, sejam eles positivos ou negativos.

Após a detecção dos períodos de existência (ou não) da bolha, comparamos com resultados do nosso modelo S2U (stocks-to-use).

O S2U consiste numa regressão linear entre a razão de estoque e uso e o preço do ativo a mercado.

Esse modelo é comumente utilizado na preficiação de commodities agrícolas, principalmente para o hedge feito com contratos futuros.

Após a identificação dos períodos de bolha no ativo, que podem ser verificados no arquivo date_bubbles.csv, criamos estratégias de trading aplicando o conceito de **mean reversion**.
