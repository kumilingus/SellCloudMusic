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
            <div class="pwdreq">
                <p>For password reset request enter your email address please.</p>
                <input id="pwdreq-email" type="email" name="email" placeholder="Email address"/>
                <input type="submit" value="Send Request">
                    <xsl:attribute name="name">
                        <xsl:value-of select ="concat(name,'-submit')"/>
                    </xsl:attribute>
                </input>
                <xsl:if test="status = 'errors'">
                    <span class="form-error">
                        <xsl:value-of select="errors"/>
                    </span>
                </xsl:if>                
                <input type="hidden" name="token">
                    <xsl:attribute name="value">
                        <xsl:value-of select="pwdreq/token"/>
                    </xsl:attribute>
                </input>
            </div>
        </form>
    </xsl:template>
</xsl:stylesheet>
