SELECT se."Name", sc."Created", st."MedianPrice" * 1000000 AS "MedianPrice", st."MeanDwellingSize"
FROM public."Settlements" se
INNER JOIN public."Scrapes" sc ON se."Id" = sc."SettlementId"
INNER JOIN public."Stats" st ON sc."Id" = st."ScrapeId"
WHERE sc."Created" = '2020-06-18' 
ORDER BY st."MedianPrice"
