# Plano de Refatoração e Correção: `webapp`

Este documento detalha as etapas necessárias para corrigir bugs críticos, melhorar a robustez e garantir a segurança do script de gerenciamento de webapps.

## 1. Resolução de Dependência de Caminho (Hardcoded Path)

**Problema:** O script assume que `webapp-launch` está em `$HOME/scripts/`.
**Solução:** Detectar dinamicamente a localização do executável `webapp-launch`.

*   **Ação:**
    *   Substituir a atribuição fixa de `EXEC_COMMAND` por uma verificação dinâmica.
    *   Utilizar `command -v webapp-launch` para encontrar o caminho absoluto do executável no sistema.
    *   **Fallback:** Se o comando não for encontrado no `$PATH`, tentar localizar no mesmo diretório onde o script `webapp` está sendo executado ou alertar o usuário de que o script auxiliar não foi encontrado.
    *   **Código sugerido (lógica):**
        ```bash
        LAUNCHER_PATH=$(command -v webapp-launch)
        if [[ -z "$LAUNCHER_PATH" ]]; then
             # Tentar fallback ou erro
             echo "Erro: webapp-launch não encontrado no PATH."
             return 1
        fi
        EXEC_COMMAND="$LAUNCHER_PATH $APP_URL $APP_NAME"
        ```

## 2. Sanitização de Nomes de Arquivo

**Problema:** Nomes de apps contendo `/` ou caracteres especiais quebram a criação de arquivos.
**Solução:** Sanitizar a entrada do usuário antes de usá-la como nome de arquivo.

*   **Ação:**
    *   Criar uma variável `SAFE_FILENAME` baseada em `APP_NAME`.
    *   Substituir barras, espaços (opcional, mas recomendado para arquivos) e caracteres de controle por `_` ou `-`.
    *   Utilizar `SAFE_FILENAME` para gerar o nome do arquivo `.desktop` e do ícone `.png`.
    *   Manter `APP_NAME` original apenas para o campo `Name=` dentro do arquivo `.desktop`.

## 3. Identificação e Descoberta de Apps (Custom Exec)

**Problema:** Apps com "Custom Exec" tornam-se invisíveis para o script, pois o filtro busca por `webapp-launch`.
**Solução:** Adicionar um metadado personalizado ao arquivo `.desktop` e atualizar a lógica de busca.

*   **Ação 1 (Instalação):**
    *   Adicionar a chave `X-WebApp-Manager=true` (ou similar) ao final do arquivo `.desktop` gerado.
*   **Ação 2 (Listagem/Remoção/Lançamento):**
    *   Atualizar o `grep` nas funções de listagem.
    *   Passar a buscar por arquivos que contenham `X-WebApp-Manager=true` **OU** (para retrocompatibilidade) contenham `webapp-launch` na linha `Exec=`.

## 4. Remoção Segura e Precisa de Ícones

**Problema:** O script tenta deletar `$ICON_DIR/$APP_NAME.png`, ignorando se o ícone real tem outra extensão ou nome.
**Solução:** Ler o caminho do ícone do arquivo `.desktop` antes de deletar.

*   **Ação:**
    *   Na função `remove_webapp`, antes de remover o `.desktop`:
        1. Extrair o valor da chave `Icon=` usando `grep` ou `awk`.
        2. Verificar se o caminho extraído está dentro de `$ICON_DIR` (para evitar deletar ícones do sistema por engano).
        3. Se estiver no diretório de usuário, remover aquele arquivo específico.

## 5. Manipulação Robusta do Waybar (JSON)

**Problema:** Uso de `sed` para editar JSON é frágil e pode corromper o arquivo de configuração.
**Solução:** Utilizar `jq` se disponível, ou implementar uma manipulação de texto mais defensiva/alertar o usuário.

*   **Ação:**
    *   Verificar se `jq` está instalado (`command -v jq`).
    *   **Cenário A (jq instalado):** Usar `jq` para adicionar/remover a entrada no `modules.json` de forma segura.
    *   **Cenário B (jq ausente):**
        *   Opção 1: Exibir aviso sugerindo a instalação do `jq`.
        *   Opção 2: Exibir as instruções manuais para o usuário adicionar a configuração.
        *   *Decisão:* Não tentar editar JSON complexo com `sed` para evitar corrupção de config do usuário.

## 6. Resolução de Colisão de Nomes (Launch/Remove)

**Problema:** Selecionar um app pelo nome falha se houverem duplicatas (nomes iguais, arquivos diferentes).
**Solução:** Utilizar o nome do arquivo (ID único) como referência interna.

*   **Ação:**
    *   Nas listas geradas para o `gum choose`, formatar a string de exibição para incluir alguma distinção se necessário, ou usar arrays associativos (Bash 4+).
    *   **Abordagem Simplificada:** Ao criar a lista para o `gum`, usar o formato: `"Nome do App [nome-do-arquivo.desktop]"`.
    *   Ao processar a seleção, extrair o texto entre colchetes `[]` para saber exatamente qual arquivo `.desktop` manipular, garantindo unicidade.

## 7. Resumo das Dependências Necessárias

Para que as correções funcionem, o script deverá verificar a presença de:
1.  `gum` (já verificado).
2.  `jq` (nova dependência recomendada para JSON).
3.  `webapp-launch` (verificar presença no PATH).
