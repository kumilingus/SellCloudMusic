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
            <div class="login">
                <xsl:if test="status = 'errors'">
                    <div class="form-error">
                        <xsl:value-of select="errors"/>
                    </div>
                </xsl:if>
                <input type="text" name="email" placeholder="email" id="login-email">
                    <xsl:attribute name="value">
                        <xsl:value-of select="login/email"/>
                    </xsl:attribute>
                </input>
                <input type="password" name="password" placeholder="password" id="login-password">
                </input>
                <input type="submit" value="login" class="btn btn-large btn-block">
                    <xsl:attribute name="name">
                        <xsl:value-of select ="concat(name,'-submit')"/>
                    </xsl:attribute>
                </input>
                <input type="hidden" name="token">
                    <xsl:attribute name="value">
                        <xsl:value-of select="login/token"/>
                    </xsl:attribute>
                </input>
            </div>
        </form>
        <div class="login-menu">
            <span id="sign-up-button">
	      Sign Up
	    </span>|
	     <span id="forgotten-password-button">
	       Forgotten Password
	     </span>|
             <span id="api-doc">
                 API Documentation
             </span>|
	     <span id="about-us">
	       SellCloudMusic
	     </span>
        </div>
    </xsl:template>
</xsl:stylesheet>
