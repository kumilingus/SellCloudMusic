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
            <div class="logout">
                <span class="logged-email"><xsl:value-of select="logout/email"/></span>
                <input type="submit" value="logout">
                    <xsl:attribute name="name">
                        <xsl:value-of select ="concat(name,'-submit')"/>
                    </xsl:attribute>
                </input>
                <input id="id-user" type="hidden" name="id_user">
                    <xsl:attribute name="value">
                        <xsl:value-of select="logout/id_user"/>
                    </xsl:attribute>                    
                </input>
                <input type="hidden" name="token">
                    <xsl:attribute name="value">
                        <xsl:value-of select="logout/token"/>
                    </xsl:attribute>
                </input>
            </div>
        </form>
        <div class="logout-menu">
            <span id="my-tracks-button">My Tracks</span>|
            <span id="edit-account-button">Edit Account</span>|
            <span id="view-orders-button">Manage Orders</span>|
            <span id="api-doc">API Documentation</span>|
            <span id="about-us">SellCloudMusic</span>
        </div>
    </xsl:template>
</xsl:stylesheet>