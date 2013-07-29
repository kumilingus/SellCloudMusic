<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html"/>
    <xsl:template match="tracks">
        <script type="text/javascript" src="js/frm.track.js"></script>
        <script type="text/javascript" src="js/lst.track.js"></script>        
        <div id="track-list">
            <xsl:apply-templates match="track"/>
        </div>
        <div id="track-panel">
            <div id="track-info"/>
            <div id="track-edit"/>
        </div>
    </xsl:template>
    <xsl:template match="/tracks/track">
        <div>
            <xsl:attribute name="class">track-label<xsl:if test="import-id != 0"> track-imported</xsl:if>
            </xsl:attribute>
            <xsl:attribute name="data-import-track-id">
                <xsl:value-of select = "number(import-id)"/>
            </xsl:attribute>
            <xsl:attribute name="data-import-user-id">
                <xsl:value-of select = "import-user-id"/>
            </xsl:attribute>            
            <xsl:attribute name="data-user-id">
                <xsl:value-of select = "user-id"/>
            </xsl:attribute>
            <xsl:attribute name="data-track-id">
                <xsl:value-of select = "id"/>
            </xsl:attribute>
            <xsl:attribute name="data-count-orders">
                <xsl:value-of select = "number(count-orders)"/>
            </xsl:attribute>
            <xsl:attribute name="data-exclusive">
                <xsl:value-of select = "number(exclusive)"/>
            </xsl:attribute>
            <xsl:value-of select="title"/>
            <div class="image-orders" title="Track has some orders"/>
            <div class="image-exclusive" title="Track is exclusive"/>
        </div>
        <div class="track-body">
            <div class="track-more">
                <xsl:if test="bpm != ''">
                    <span class="key bpm">BPM:</span>
                    <span class="val bpm">
                        <xsl:value-of select="bpm"/>
                    </span>
                </xsl:if>
                <span class="key downloadable">Downloadable:</span>
                <span class="val downloadable">
                    <xsl:value-of select="downloadable"/>
                </span>
                <span class="key download-count">Download count:</span>
                <span class="val download-count">
                    <xsl:value-of select="download-count"/>
                </span>
                <span class="key purchase-url">Purchase URL:</span>
                <span class="val purchase-url">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select = "purchase-url"/>
                        </xsl:attribute>
                        <xsl:value-of select="purchase-url"/>
                    </a>
                </span>

            </div>
            <iframe class="track-player" width="100%" height="166" scrolling="no" frameborder="no">
                <xsl:attribute name="src">
                    <xsl:value-of select = "concat('https://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F',id,'%3Fsecret_token%3D',secret-token)"/>
                </xsl:attribute>
            </iframe>
            <xsl:if test="description != ''">
                <div class="track-description white-box">
                    <xsl:value-of select="description"/>
                </div>
            </xsl:if>
        </div>            
    </xsl:template>
</xsl:stylesheet>