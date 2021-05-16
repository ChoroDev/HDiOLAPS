USE [hdiolaps]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DimTimeYear](
	[Id_year] [int] NOT NULL,
 CONSTRAINT [PK_DimTimeYear] PRIMARY KEY CLUSTERED 
(
	[Id_year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[DimPublisher](
	[id_Publisher] [int] IDENTITY(1,1) NOT NULL,
	[Issue] [int] NULL,
	[Volume] [nvarchar](50) NULL,
	[ISSN] [nvarchar](50) NULL,
	[DOI] [nvarchar](50) NULL,
	[Title] [nvarchar](500) NOT NULL,
	[AddInform] [nvarchar](500) NULL,
	[TypeOf] [nvarchar](50) NULL,
	[Science] [nvarchar](100) NULL,
 CONSTRAINT [PK_Publisher] PRIMARY KEY CLUSTERED 
(
	[id_Publisher] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[DimVAK](
	[Id_journal] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](255) NULL,
	[TypeOfScience] [nvarchar](255) NULL,
	[ALLTypes] [nvarchar](500) NULL,
 CONSTRAINT [PK_VAK] PRIMARY KEY CLUSTERED 
(
	[Id_journal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[DimAuthors](
	[Id_author] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	
 CONSTRAINT [PK_AVTORS] PRIMARY KEY CLUSTERED 
(
	[Id_author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[DimDate](
	[id_date] [int] IDENTITY(1,1) NOT NULL,
	[year] [smallint] NULL,
	[month] [nvarchar](20) NULL,
	[day] [smallint] NULL,
	[date] [smalldatetime] NULL,
 CONSTRAINT [PK_date] PRIMARY KEY CLUSTERED 
(
	[id_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[DimPublication](
	[ID_publ] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](500) NULL,
	[Source] [int] NULL,
	[CountAuthors] [tinyint] NULL,
	[Abstract] [ntext] NULL,
	[Cites] [smallint] NULL,
	[QueryDate] [int] NULL,
	[Year] [int] NULL,
 CONSTRAINT [PK_publ] PRIMARY KEY CLUSTERED 
(
	[ID_publ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[DimPublication]  WITH CHECK ADD  CONSTRAINT [FK_Publ_DimTimeYear] FOREIGN KEY([Year])
REFERENCES [dbo].[DimTimeYear] ([Id_year])
GO

ALTER TABLE [dbo].[DimPublication] CHECK CONSTRAINT [FK_Publ_DimTimeYear]
GO

ALTER TABLE [dbo].[DimPublication]  WITH CHECK ADD  CONSTRAINT [FK_Publication_Publisher] FOREIGN KEY([Source])
REFERENCES [dbo].[DimPublisher] ([id_Publisher])
GO
ALTER TABLE [dbo].[DimPublication] CHECK CONSTRAINT [FK_Publication_Publisher]
GO


CREATE TABLE [dbo].[FactPublOfAuthor](
	[ID_POF] [int] IDENTITY(1,1) NOT NULL,
	[ID_publ] [int] NOT NULL,
	[ID_author] [int] NOT NULL,
	unique ([ID_publ],[ID_author]),
 CONSTRAINT [PK_PublOfAuthor] PRIMARY KEY CLUSTERED 
(
	[ID_POF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 


GO

ALTER TABLE [dbo].[FactPublOfAuthor]  WITH CHECK ADD  CONSTRAINT [UC_PublOfAuthor] CHECK ([ID_publ] IS NOT NULL AND [ID_author] IS NOT NULL)
GO

ALTER TABLE [dbo].[FactPublOfAuthor]  WITH CHECK ADD  CONSTRAINT [FK_PublOfAuthor_Authors] FOREIGN KEY([ID_author])
REFERENCES [dbo].[DimAuthors] ([Id_author])
GO

ALTER TABLE [dbo].[FactPublOfAuthor] CHECK CONSTRAINT [FK_PublOfAuthor_Authors]
GO

ALTER TABLE [dbo].[FactPublOfAuthor]  WITH CHECK ADD  CONSTRAINT [FK_PublOfAuthor_Publication] FOREIGN KEY([ID_publ])
REFERENCES [dbo].[DimPublication] ([ID_publ])
GO

CREATE PROCEDURE  [dbo].[AddPublOfAuthor]  (@authors nvarchar(255), @IDP int)
	-- Add the parameters for the stored procedure here
AS
 DECLARE @I SMALLINT,  @newAutor nvarchar(100)

BEGIN 
 SET NOCOUNT ON;
 SET @authors=TRIM(@authors)
 SET @I = 1
 WHILE @I<=LEN(@authors)
 BEGIN
  IF SUBSTRING(@authors,@I,1)<>',' 
    BEGIN
      SET @newAutor= @newAutor+SUBSTRING(@authors,@I,1) 
      SET @I=@I+1
    END
   ELSE  
	BEGIN 
	 IF (NOT EXISTS (SELECT * FROM [dbo].[DimAuthors] where DimAuthors.Name=@newAutor)) AND @newAutor<>''  insert into DimAuthors(Name) values (@newAutor)
	
	 IF (NOT EXISTS (SELECT * FROM [dbo].[FactPublOfAuthor] where [ID_publ]=@IDP and 	 [ID_author] =(select [dbo].[DimAuthors].[Id_author] from [dbo].[DimAuthors] where DimAuthors.Name=@newAutor)))
	  INSERT INTO [dbo].[FactPublOfAuthor]([ID_publ], [Id_author]) SELECT ID_publ, [Id_author] FROM [dbo].[DimAuthors], [dbo].[DimPublication] 
	 WHERE @newAutor=[dbo].[DimAuthors].Name AND @IDP=[dbo].[DimPublication].[ID_publ]
	 SET @newAutor=''
	 SET @I=@I+2;
	END
  END
 IF (NOT EXISTS (SELECT * FROM [dbo].[DimAuthors] where DimAuthors.Name=@newAutor)) AND @newAutor<>'' insert into DimAuthors(Name) values (@newAutor);

  IF (NOT EXISTS (SELECT * FROM [dbo].[FactPublOfAuthor] where [ID_publ]=@IDP and [ID_author] =(select [dbo].[DimAuthors].[Id_author] from [dbo].[DimAuthors] where DimAuthors.Name=@newAutor)))
	  INSERT INTO [dbo].[FactPublOfAuthor]([ID_publ], [Id_author]) SELECT ID_publ, [Id_author] FROM [dbo].[DimAuthors], [dbo].[DimPublication] 
	 WHERE @newAutor=[dbo].[DimAuthors].Name AND @IDP=[dbo].[DimPublication].[ID_publ]
 END

	