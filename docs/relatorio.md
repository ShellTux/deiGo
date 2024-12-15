# DeiGo - Compiladores 2024

---
title: Relatório Compiladores
authors:
  - João Fonseca, nº 2021227194
  - Luís Pedro de Sousa Oliveira Góis, nº 2018280716
date: \today
---

## Introdução

Este projeto consiste no desenvolvimento de um compilador para a linguagem
DeiGo, que é um subconjunto da linguagem go. Com o objetivo de compreender
melhor como criar um compilador, o projeto foi dividido em quatro metas:

1. Análise lexical (meta 1)
2. Análise sintática (meta 2)
3. Análise semântica (meta 3)
4. Geração de código (meta 4)

Este relatório tem como propósito destacar algumas decisões tomadas durante o
desenvolvimento do projeto.

## Gramática

Na meta 2, foi necessário realizar alterações para adequar uma gramática
inicial ambígua escrita em notação EBNF à análise lexical realizada na meta 1.
A gramática foi reescrita para YACC, levando em consideração as regras de
associação dos operadores e as precedências, entre outros aspetos, a fim de
garantir a compatibilidade entre as linguagens DeiGo e Go.

Tendo em conta que poderiam existir símbolos terminais ou não terminais,
opcionais [] , que apareciam zero ou mais vezes {} ou dos quais apenas se pode
escolher um (), foi necessario reescrever a gramática de modo a obter
expressoes recursivas Estas adaptações foram cruciais para garantir a coesão
entre a gramática da linguagem DeiGo e a análise sintática realizada. Para
evitar conflitos entre símbolos não terminais, definimos a prioridade para cada
um dos símbolos não terminais, resolvendo assim o problema das precedências


## Algoritmos e estruturas de dados da AST e da tabela de símbolos

Ainda na meta 2 foi desenvolvida uma árvore de sintaxe abstrata para ser
possível fazer a análise sintática e semântica. Com este objetivo, foi criada
uma estrutura `Struct Node` (árvore). Constituída pelos campos `enum Category
tokenType` e   `char *tokenValue`, associando o "token" e o id ao nó, bem como
um ponteiro para o novo nível da AST que liga o nó pai com o filho ou filhos
`struct NodeList *children` Para a criação de um novo nó na árvore foi criada a
função struct Node *createNode, onde é passado o parâmetro nome e tipo, em
seguida são utilizadas as funções "addChild", “addChilds"," addNode" e
"addNodes" para construção da arvore e ligação dos nós mediante as ocorrências
da gramática em função dos casos de teste analisados de modo a conectar todos
os nós da arvore no local correto.

A estrutura de dados da tabela de símbolos (`struct SymbolList`) representa um
sistema para gerir e organizar informações sobre identificadores num programa,
incluindo suas declarações, tipos e scope. Cada entrada na tabela de símbolos
representa um identificador do código-fonte, como variáveis, funções ou
parâmetros. O tipo do identificador, como variável local, global ou função, é
armazenado no campo type. O campo node liga a tabela de símbolos à árvore de
análise sintática, associando os identificadores a informações semânticas
específicas. Para permitir a iteração sobre os símbolos no mesmo nível de
escopo, utiliza-se o campo next, enquanto o campo scope aponta para a tabela de
símbolos de um escopo interno, facilitando a representação hierárquica de
blocos aninhados ou funções.

## Geração de Código A geração de código implementa funcionalidades básicas

Para traduzir uma árvore de análise sintática em código intermediário LLVM. O
processo foca em expressões, parâmetros e funções simples, e é projetado para
suportar declarações e chamadas de funções com argumentos inteiros.
