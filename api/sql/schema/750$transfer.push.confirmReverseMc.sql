ALTER PROCEDURE [transfer].[push.confirmReverseMc]
    @reverseId bigint,
    @transferId bigint,
    @transferIdIssuer varchar(50),
    @issuerResponseCode varchar(10), 
    @issuerResponseMessage varchar(250) = NULL,
    @originalResponse TEXT = NULL,
    @stan char(6) = NULL,
    @networkData varchar(20) = NULL,
    @isPartialReverse BIT=0
AS
SET NOCOUNT ON

BEGIN TRY
    BEGIN TRANSACTION

    UPDATE
        [transfer].[reverse]
    SET
        issuerTxState = 2,
        issuerResponseCode = @issuerResponseCode,
        issuerResponseMessage = @issuerResponseMessage,
        originalResponse = @originalResponse,
        stan = @stan,
        networkData = @networkData,
        transferIdIssuer = @transferIdIssuer,
        updatedOn = GETDATE()
    WHERE
        reverseId = @reverseId
    IF @isPartialReverse=0
    BEGIN
	   UPDATE
		  [transfer].[transfer]
	   SET
		  reversed = 1
	   WHERE
		  transferId = @transferId

	   UPDATE
		  [transfer].[transfer]
	   SET
		  reversed = 1
	   WHERE
		  originalTransferId = @transferId
    END

    EXEC [transfer].[push.event]
        @transferId = @transferId,
        @type = 'transfer.reverse',
        @state = 'reverse',
        @source = 'acquirer',
        @message = 'Transaction was succesfully reversed',
        @udfDetails = null

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    if @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    EXEC core.error
    RETURN 55555
END CATCH
