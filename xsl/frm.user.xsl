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
                        <label for="paypal-email">Paypal account:</label>
                    </td>
                    <td>
                        <input id="paypal-email" type="text" name="paypal_email">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/paypal_email"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
		<tr>
		  <td></td>
		  <td>
		    <small><a href="https://www.paypal.com/uk/cgi-bin/webscr?cmd=_registration-run" target="_blank">Create PayPal account</a></small>
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
                    <td>Invoice address:</td>
                    <td>
                        <input id="user-address-company" type="text" name="address_company name" placeholder="Company name">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/address_company_name"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td><small>(optional)</small></td>
                    <td>
                        <input id="user-address-street" type="text" name="address_number_street" placeholder="Street number and name">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/address_number_street"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <input id="user-address-town" type="text" name="address_town" placeholder="Town or City">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/address_town"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <input id="user-address-zip" type="text" name="address_zip" placeholder="ZIP code">
                            <xsl:attribute name="value">
                                <xsl:value-of select="user/address_zip"/>
                            </xsl:attribute>
                        </input>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="submit">
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="prev_status = 'new'">Sign up</xsl:when>
                                    <xsl:otherwise>Update Account</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
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