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
                <xsl:if test="status != 'load' and status != 'errors' and status != 'new'">
                    <tr>
                        <td  colspan="2">
                            <div class="form-info">
                                <xsl:choose>
                                    <xsl:when test="status = 'insert'">User sucessfuly registred.</xsl:when>
                                    <xsl:when test="status = 'update'">User informations were sucessfully updated.</xsl:when>
                                </xsl:choose>
                            </div>
                        </td>
                    </tr>
                </xsl:if>                
                <tr>
                    <td>
                        <label for="email">Email address:</label>
                    </td>
                    <td>
                        <input id="user-email" type="text" name="email">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/email"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="user-password">Password:</label>
                    </td>
                    <td>
                        <input id="user-password" type="password" name="password"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="user-password-re">Re-password:</label>
                    </td>
                    <td>
                        <input id="user-password-re" type="password" name="password_re"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="soundcloud-connect">Soundcloud account:</label>                        
                    </td>
                    <td>
                        <input id="soundcloud-connect" type="button"/>
                        <span id="soundcloud-connected">
                            <xsl:if test="user/soundcloud_username != ''">
                                <xsl:value-of select ="user/soundcloud_username"/>
                            </xsl:if>
                        </span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="submit" value="confirm">
                            <xsl:attribute name="name">
                                <xsl:value-of select ="concat(name,'-submit')"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input id="soundcloud-username" type="hidden" name="soundcloud_username">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/soundcloud_username"/>
                            </xsl:attribute>                            
                        </input>
                        <input id="soundcloud-oauth-token" type="hidden" name="soundcloud_oauth_token">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/soundcloud_oauth_token"/>
                            </xsl:attribute>
                        </input>
                        <input type="hidden" name="token">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/token"/>
                            </xsl:attribute>
                        </input>
                        <input type="hidden" name="id_user">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/id_user"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
            </table>        
        </form>
    </xsl:template>
</xsl:stylesheet>