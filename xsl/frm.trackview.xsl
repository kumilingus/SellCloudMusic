<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"/>
    <xsl:template match="/form">
        <form>
            <xsl:attribute name="class">
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
            <fieldset>
                <span class="exclusivity">
                    <xsl:if test="trackview/exclusive = 1"> not</xsl:if> exlusive
                </span>
                <span class="title">
                    <xsl:value-of select="trackview/track/title"/>
                </span>
                <span class="text">by</span>
                <span class="username">
                    <xsl:value-of select="trackview/user/username"/>
                </span>
                <span class="text">for</span>
                <span class="price">
                    $ <xsl:value-of select="trackview/price"/>
                </span>
                <iframe class="track-player" width="100%" height="166" scrolling="no" frameborder="no">
                    <xsl:attribute name="src">
                        <xsl:value-of select = "concat('https://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F',trackview/id_soundcloud)"/>
                    </xsl:attribute>
                </iframe>

                <input type="hidden" name="cmd" value="_cart" />
                <input type="hidden" name="add" value="1" />
                <input type="hidden" name="business">
                    <xsl:attribute name="value">
                        <xsl:value-of select="paypal_account"/>
                    </xsl:attribute>
                </input>
                <!-- custom attribute passes the user id -->
                <input type="hidden" name="custom">
                    <xsl:attribute name="value">
                        <xsl:value-of select="trackview/id_user"/>
                    </xsl:attribute>
                </input>
                <input type="hidden" name="cancel_return">
                    <xsl:attribute name="value">
                        <xsl:value-of select="return_url"/>
                    </xsl:attribute>
                </input>
                <input type="hidden" name="return">
                    <xsl:attribute name="value">
                        <xsl:value-of select="return_url"/>
                    </xsl:attribute>
                </input>
                <input type="hidden" name="notify_url" value="http://86.21.126.98/sellcloudmusic/order.php" />
                <input type="hidden" name="item_name">
                    <xsl:attribute name="value">
                        <xsl:value-of select="trackview/track/title"/>                        
                    </xsl:attribute>                    
                </input>
                <input type="hidden" name="item_number">
                    <xsl:attribute name="value">
                        <xsl:value-of select="trackview/id_track"/>
                    </xsl:attribute>                    
                </input>                
                <input type="hidden" name="amount">
                    <xsl:attribute name="value">
                        <xsl:value-of select="trackview/price"/>
                    </xsl:attribute>
                </input>                
                <input type="hidden" name="currency_code" value="GBP" />
                <input type="hidden" name="token">
                    <xsl:attribute name="value">
                        <xsl:value-of select="trackview/token"/>
                    </xsl:attribute>
                </input>
                <input type="submit" value="Add to cart">
                    <xsl:attribute name="name">
                        <xsl:value-of select ="concat(name,'-submit')"/>
                    </xsl:attribute>
                </input>
            </fieldset>
        </form>
        <div class="more-tracks">
            <xsl:attribute name="data-id-user">
                <xsl:value-of select="trackview/id_user"/>
            </xsl:attribute>            
            <span class="text">More tracks from <xsl:value-of select="trackview/user/username"/>:</span>
        </div>
        <script type="text/javascript" src="js/frm.trackview.js"></script>
        <script type="text/javascript" src="lib/paypal/minicart.js"></script>
        <script>
            PAYPAL.apps.MiniCart.render({paypalURL:'https://www.sandbox.paypal.com/cgi-bin/webscr',events:{onAddToCart:function(data){if(this.getProductAtOffset(data.offset)){return false;}}}});
        </script>
    </xsl:template>
</xsl:stylesheet>