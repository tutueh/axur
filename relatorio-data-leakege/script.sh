TOKEN='SEU TOKEN AQUI'

ONE_HOUR_AGO=$(TZ='America/Sao_Paulo' date --date='-120 days' +"%Y-%m-%dT%H:%M:%S")
CURRENT_TIME=$(TZ='America/Sao_Paulo' date +"%Y-%m-%dT%H:%M:%S")
SORT_FIELD="open.date"
PAGES=2
TICKET_PER_PAGE=200

TICKET_QUERY="open.date=ge:${ONE_HOUR_AGO}&open.date=le:${CURRENT_TIME}&current.status=open&current.type=infostealer-credential&sortBy=${SORT_FIELD}&page=${PAGES}&pageSize=${TICKET_PER_PAGE}&order=asc&utc=-03:00"

SEARCH=$(curl --noproxy "*" \
-sLX GET "https://api.axur.com/gateway/1.0/api/tickets-api/tickets?${TICKET_QUERY}" \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer ${TOKEN}")

echo "$SEARCH" | jq -r '.tickets[].ticket.ticketKey' | while read -r ticketKey; do
    curl --noproxy "*" \
    -sLX GET "https://api.axur.com/gateway/1.0/api/tickets-infostealer-credentials/tickets/$ticketKey" \
    -H "Authorization: Bearer $TOKEN" | jq -r '.leaks[] | "Data do vazamento: \(.date / 1000 | strftime("%d/%m/%Y %H:%M:%S")) | Tipo de Dado: \(.userType) | Credencial Identificada: \(.username) | Senha Identificada: \(.password) | Fonte: \(.sourceName) | URL Alvo: \(.sourceURI)"'
done > /tmp/rascunho-limpeza-axur

sort /tmp/rascunho-limpeza-axur | uniq > axur-dados-vazados.txt
rm -f /tmp/rascunho-limpeza-axur
echo "Processamento concluído e dados salvos em axur-dados-vazados.txt"
