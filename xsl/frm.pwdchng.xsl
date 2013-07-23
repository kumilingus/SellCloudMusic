<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
            <pre>Enter your new password please.</pre>
            <table class="form-table">
                <xsl:if test="status = 'errors'">
                    <tr>
                        <td colspan="2">
                            <div class="form-error">
                                <xsl:value-of select="errors"/>
                            </div>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td>
                        <input id="user-password" type="password" name="password" placeholder="New Password"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input id="user-password-re" type="password" name="password_re" placeholder="Confirm Password"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="submit" value="change">
                            <xsl:attribute name="name">
                                <xsl:value-of select ="concat(name,'-submit')"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>                
                <tr>
                    <td>
                        <input type="hidden" name="token">
                            <xsl:attribute name="value">
                                <xsl:value-of select="pwdchng/token"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
            </table>        
        </form>
    </xsl:template>
</xsl:stylesheet>
