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
                <tbody>
                    <xsl:if test="status = 'errors'">
                        <tr class="track-table-row">
                            <td  colspan="2">
                                <div class="form-error">
                                    <xsl:value-of select="errors"/>
                                </div>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="status != 'load' and status != 'new' and status != 'errors'">
                        <tr class="track-table-row">
                            <td colspan="2">
                                <div class="form-info">
                                    <xsl:choose>
                                        <xsl:when test="status = 'insert'">Track imported.</xsl:when>
                                        <xsl:when test="status = 'delete'">Track removed.</xsl:when>
                                        <xsl:when test="status = 'update'">Track updated.</xsl:when>
                                    </xsl:choose>
                                </div>
                            </td>
                        </tr>
                    </xsl:if>
                    <tr class="track-table-row">
                        <td class="track-table-first-column">
                            <label for="track-price">Price:</label>
                        </td>
                        <td>
                            <span class="currency">$</span>
                            <input type="text" id="track-price" name="price">
                                <xsl:attribute name="value">
                                    <xsl:value-of select="track/price"/>
                                </xsl:attribute>
                            </input>
                            <div id="slider-range-min"></div>
                        </td>
                    </tr>
<!--                    
                    <tr class="track-table-row">
                        <td class="track-table-first-column">
                            <span id="track-exclusive">Exclusivity:</span>
                        </td>
                        <td>
                            <div id="exclusive-radio">
                                <input type="radio" id="radio1" name="exclusive" value="2">
                                    <xsl:if test="track/exclusive = 2">
                                        <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                </input>
                                <label for="radio1">Exclusive</label>
                                <input type="radio" id="radio2" name="exclusive" value="1">
                                    <xsl:if test="track/exclusive = 1">
                                        <xsl:attribute name="checked">checked</xsl:attribute>
                                    </xsl:if>
                                </input>
                                <label for="radio2">Non-exclusive</label>
                            </div>
                        </td>
                    </tr>
-->
                    <tr class="track-table-row">
                        <td colspan = "2">
                            <input type="submit" value="Offer For Sale">
                                <xsl:attribute name="name">
                                    <xsl:value-of select ="concat(name,'-submit')"/>
                                </xsl:attribute>
                                <xsl:if test="track/id_track &gt; 0">
                                    <xsl:attribute name="value" >Save Changes</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:if test="track/id_track &gt; 0">
                                <button id="remove-track-button">Withdraw From Sale</button>
                            </xsl:if>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <input type="hidden" name="token">
                                <xsl:attribute name="value">
                                    <xsl:value-of select="track/token"/>
                                </xsl:attribute>
                            </input>
                            <input type="hidden" name="id_track">
                                <xsl:attribute name="value">
                                    <xsl:value-of select="track/id_track"/>
                                </xsl:attribute>
                            </input>
                            <input type="hidden" name="count_orders">
                                <xsl:attribute name="value">
                                    <xsl:value-of select="track/count_orders"/>
                                </xsl:attribute>
                            </input>
                        </td>
                    </tr>
                </tbody>
            </table>
        </form>
        <xsl:if test="track/count_orders &gt; 0">
            <div class="white-box">
                Orders ( <xsl:value-of select="track/count_orders"/> )
                <span id="display-orders" class="button"> Display </span>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>