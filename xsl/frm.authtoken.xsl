<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html"/>
    <xsl:template match="/form">
        <form>
            <xsl:attribute name="id">
                <xsl:value-of select="name"/>
            </xsl:attribute>
            <xsl:attribute name="name">
                <xsl:value-of select="name"/>
            </xsl:attribute>
            <xsl:attribute name="action">
                <xsl:value-of select="action"/>
            </xsl:attribute>
            <xsl:attribute name="method">
                <xsl:value-of select="method"/>
            </xsl:attribute>
            <span>
                Authorization token:
            </span>
            <span class="auth-token">
                <xsl:value-of select="authtoken/auth_token"/>
            </span>
            <input type="submit" value="Generate New">
                <xsl:attribute name="name">
                    <xsl:value-of select ="concat(name,'-submit')"/>
                </xsl:attribute>
            </input>
            <input type="hidden" name="token">
                <xsl:attribute name="value">
                    <xsl:value-of select="authtoken/token"/>
                </xsl:attribute>
            </input>
            <input type="hidden" name="id_user">
                <xsl:attribute name="value">
                    <xsl:value-of select="authtoken/id_user"/>
                </xsl:attribute>
            </input>                
        </form>
    </xsl:template>
</xsl:stylesheet>
