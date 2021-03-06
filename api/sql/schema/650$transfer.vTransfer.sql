ALTER VIEW [transfer].vTransfer AS
SELECT * ,
    ISNULL(t.acquirerFee, 0) + ISNULL(t.issuerFee, 0) + ISNULL(t.transferFee, 0) AS amountBilling,
    ISNULL(t.transferAmount, 0) + ISNULL(t.acquirerFee, 0) + ISNULL(t.issuerFee, 0) + ISNULL(t.transferFee, 0)	AS amountSettlement,
    CASE
        WHEN ((t.channelType IN ('iso', 'web', 'pos') AND t.[issuerTxState] IN (2, 8, 12)) OR [acquirerTxState] IN (2, 8, 12)) THEN 1
        ELSE 0
    END success
FROM
    [transfer].[transfer] t
WHERE
    ISNULL(reversed, 0) = 0
