
# Divisão e Raiz Quadrada em Assembly 16-bits

#### DEFINIÇÃO DO PROBLEMA
Recorrendo à programação em linguagem Assembly para processadores de 16-bits, o objetivo deste projeto é desenvolver um algoritmo capaz de efetuar os cálculos da divisão e da raiz quadrada.

É também objetivo desenvolver um interface gráfico para a introdução e apresentação de dados.

#### CARACTERÍSTICAS GERAIS DO PROGRAMA 
- É usado o modo gráfico 320x200 com 256 cores;
- Para a introdução de dados é usado um teclado virtual em que os botões são posicionados sempre aleatóriamente;
- Há interação com periféricos: rato e teclado.

#### PSEUDOCÓDIGO DA DIVISÃO 
1. Recebe o dividendo e o divisor;
2. Identifica o primeiro algarismo mais à esquerda do dividendo;
3. Concatena-o ao resto e verifica qual o valor mais alto que a multiplicar pelo divisor, o resultado seja inferior ou igual ao resto;
4. Subtrai ao resto o resultado dessa multiplicação e o valor encontrado é concatenado ao quociente;
5. Repetir os passos 3 e 4 até percorrer todos os algarismos do dividendo, da esquerda para a direita.

#### PSEUDOCÓDIGO DA RAIZ QUADRADA 
1. Recebe o radicando;
2. Divide os algarismos da parte inteira em pares da direita para a esquerda;
3. Divide, caso existam, os algarismos da parte decimal em pares da esquerda para a direita;
4. Identifica o primeiro par e soma-o ao resto;
5. Inicializa uma variável "a" a zero;
6. Executa a expressão "(2 * raiz * 10 + a");
7. Verifica se o resultado obtido no passo 6 é superior ao valor do resto:
- Se não, incrementa o "a" e salta para o passo 6;
- Se sim, decrementa o "a";
8. Subtrai ao resto o resultado que se obtém executando novamente o passo 6;
9. Concatena o valor "a" à raiz;
10. Verifica se já percorreu todos os pares do radicando:
- Se não, identifica o próximo par, concatena-o ao resto e salta para o passo 5;
- Se sim, fim do algoritmo.

#### 💻Para testar a aplicação é necessário instalar o DOSBox, compilar o ficheiro 'Ficheiros/programa.asm' e executar o executável gerado pelo DOSBox.
