SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_ParishAreas]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_ParishAreas] AS' 
END
GO

-- =============================================
-- api_custom_ParishAreas
-- =============================================
-- Description:		This stored procedure returns Staff Members
-- Last Modified:	01/08/2025
-- Brian Zerangue
-- Updates:
-- 01/08/2025		- Initial Commit
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_ParishAreas] 
	@DomainID int,
	@UserName nvarchar(75) = null
AS
BEGIN

	-- DataSet1 - Parishes
	SELECT 
	    Parish_ID, 
	    Parish, 
	    Parish_Description, 
	    Geographic_Points, 
	    Geographic_Centerpoint, 
	    CASE 
	        WHEN ISJSON(REPLACE(REPLACE(GeoJSON_Markup, CHAR(10), ''), CHAR(13), '')) = 1 
	        THEN REPLACE(REPLACE(GeoJSON_Markup, CHAR(10), ''), CHAR(13), '') 
	        ELSE NULL 
	    END AS GeoJSON, 
	    Contact_ID 
	FROM 
	    Parishes
	
	ORDER BY Parish ASC

END


-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_ParishAreas'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Parish Area Widget Data'

IF NOT EXISTS (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName)
BEGIN
	INSERT INTO dp_API_Procedures
	(Procedure_Name, Description)
	VALUES
	(@spName, @spDescription)	
END


DECLARE @AdminRoleID INT = (SELECT Role_ID FROM dp_Roles WHERE Role_Name='Administrators')
IF NOT EXISTS (SELECT * FROM dp_Role_API_Procedures RP INNER JOIN dp_API_Procedures AP ON AP.API_Procedure_ID = RP.API_Procedure_ID WHERE AP.Procedure_Name = @spName AND RP.Role_ID=@AdminRoleID)
BEGIN
	INSERT INTO dp_Role_API_Procedures
	(Domain_ID,  API_Procedure_ID, Role_ID)
	VALUES
	(1, (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName), @AdminRoleID)
END
GO
-- ========================================================================================