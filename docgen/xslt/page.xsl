<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="sidebar-index">
	<div id="sidebar-index">
		<h2 id="sidebar-index-header-files">Files</h2>
		<table id="sidebar-index-table-files">
			<tr class="sidebar-index-table-heading">
				<th>Name</th>
				<th>Path</th>
			</tr>
			<xsl:for-each select="index/files/file">
				<tr>
					<td><xsl:value-of select="name"/></td>
					<td><xsl:value-of select="path"/></td>
				</tr>
			</xsl:for-each>
		</table>
		<h2 id="sidebar-index-header-libraries">Libraries</h2>
		<table id="sidebar-index-table-files">
			<tr class="sidebar-index-table-heading">
				<th>Name</th>
				<th>Summary</th>
			</tr>
			<xsl:for-each select="index/libraries/library">
				<tr>
					<td><xsl:value-of select="name"/></td>
					<td><xsl:value-of select="summary"/></td>
				</tr>
			</xsl:for-each>
		</table>
	</div>
</xsl:template>

<xsl:template match="index-page">
	<html>
	<head>
		<link rel="stylesheet" type="text/css" href="style.css" />
		<title>Index</title>
	</head>
	<body>
	<xsl:call-template name="sidebar-index"/>
	<div class="content" id="index-content">
		<h1>Index</h1>
		<hr />
		<h2>Files</h2>
		<table class="index-table" id="index-table-files">
			<tr class="index-table-heading">
				<th>Name</th>
				<th>Path</th>
			</tr>
			<xsl:for-each select="index/files/file">
				<tr>
					<td><xsl:value-of select="name"/></td>
					<td><xsl:value-of select="path"/></td>
				</tr>
			</xsl:for-each>
		</table>
		<h2>Libraries</h2>
		<table class="index-table" id="index-table-files">
			<tr class="index-table-heading">
				<th>Name</th>
				<th>Summary</th>
			</tr>
			<xsl:for-each select="index/libraries/library">
				<tr>
					<td><xsl:value-of select="name"/></td>
					<td><xsl:value-of select="summary"/></td>
				</tr>
			</xsl:for-each>
		</table>
	</div>
	<div class="footer" id = "index-footer">
		Generated with Colonel Thirty Two's SF Taglet + XML Doclet for LuaDoc
	</div>
	</body>
	</html>
</xsl:template>


</xsl:stylesheet>