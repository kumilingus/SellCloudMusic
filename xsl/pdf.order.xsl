<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:variable name="VAT" select="21"/>
    <xsl:template match="/order">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <!--
                A4: 217mm x 297mm
                body: 180mm x 280mm     
            -->
            <fo:layout-master-set>
                <fo:simple-page-master margin-bottom="7mm" margin-left="19mm" margin-right="18mm"
                                       margin-top="1cm" master-name="invoice-page-master">
                    <fo:region-body margin-bottom="20mm" margin-top="40mm"/>
                    <fo:region-before extent="30mm"/>
                    <fo:region-after extent="10mm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="invoice-page-master">
        
                <fo:static-content flow-name="xsl-region-before">
                    <fo:block-container absolute-position="absolute" left="100mm" top="Omm">
                        <fo:block> 
                            <fo:external-graphic src="url('quattroclix.png')"/>
                        </fo:block>
                    </fo:block-container>
                </fo:static-content>
        
                <fo:static-content flow-name="xsl-region-after">
                    <fo:block font-size="10pt" border-top="solid" border-top-color="black" padding-top="2mm">
                        <fo:inline>www.sellcloudmusic.com | 4 Stockbreach Close, AL100AX, Hatfield, United Kingdom</fo:inline>
                    </fo:block>
                    <fo:block font-size="10pt">
                        <fo:inline>SellCloudMusic © 2013</fo:inline>
                    </fo:block>
                </fo:static-content>
        
                <fo:flow flow-name="xsl-region-body">
                    <fo:table width="100%">
                        <fo:table-column column-width="60%"/>
                        <fo:table-column column-width="40%"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:table width="75%" font-size="16pt">
                                        <fo:table-column column-width="40%"/>
                                        <fo:table-column column-width="60%"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell>
                                                    <fo:block>Invoice:</fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell>
                                                    <fo:block>
                                                        <xsl:value-of select="txn_id"/>
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell>
                                                    <fo:block>Date:</fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell>
                                                    <fo:block>
                                                        <xsl:value-of select="substring(timestamp,0,11)"/>
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                    
                                        </fo:table-body>
                                    </fo:table>
                            
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block font-size="14pt">
                                        <fo:block><xsl:value-of select="user/address_company_name"/></fo:block>
                                        <fo:block><xsl:value-of select="user/address_number_street"/></fo:block>
                                        <fo:block><xsl:value-of select="user/address_town"/></fo:block>
                                        <fo:block><xsl:value-of select="user/address_zip"/></fo:block>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
            
                    <fo:block padding-top="20mm">
                        <fo:block font-family="sans-serif" font-size="10pt" margin-top="10mm">
                            <fo:table border-style="solid" table-layout="fixed" width="100%">
                                <fo:table-column column-width="95mm"/>
                                <fo:table-column column-width="15mm"/>
                                <fo:table-column column-width="25mm"/>
                                <fo:table-column column-width="15mm"/>
                                <fo:table-column column-width="23mm"/>
                                <fo:table-header background-color="#f39c12" text-align="center">
                                    <fo:table-row>
                                        <fo:table-cell border-style="solid" padding="1mm">
                                            <fo:block font-weight="bold">Product Description</fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell border-style="solid" padding="1mm">
                                            <fo:block font-weight="bold">Quant.</fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell border-style="solid" padding="1mm">
                                            <fo:block font-weight="bold">Unit Price</fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell border-style="solid" padding="1mm">
                                            <fo:block font-weight="bold">VAT</fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell border-style="solid" padding="1mm">
                                            <fo:block font-weight="bold">Price</fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-header>
                                <fo:table-body>
                                    <xsl:for-each select="items/item">
                                        <fo:table-row background-color="#ecf0f1">
                                            <fo:table-cell padding="1mm">
                                                <fo:block>
                                                    <xsl:value-of select="item_name"/>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell padding="1mm">
                                                <fo:block>1</fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell padding="1mm">
                                                <fo:block>$ <xsl:value-of select="format-number((100 * mc_gross_) div (100 + $VAT),'#.00')"/></fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell padding="1mm">
                                                <fo:block><xsl:value-of select="$VAT"/>&#37;</fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell padding="1mm">
                                                <fo:block text-align="right">$ <xsl:value-of select="mc_gross_"/></fo:block>
                                            </fo:table-cell>
                                        </fo:table-row>
                                    </xsl:for-each>
                                    <fo:table-row>
                                        <fo:table-cell border-style="solid" background-color="#bdc3c7" number-columns-spanned="5" padding="1mm" padding-top="2mm">
                                            <fo:block font-style="backslant" text-align="right" font-weight="bold">
                                                <fo:inline padding-right="7mm">Total TVAC</fo:inline>
                                                <fo:inline>$ <xsl:value-of select="format-number(sum(items/item/mc_gross_),'#.00')"/></fo:inline>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                    
                                </fo:table-body>
                            </fo:table>
                        </fo:block>
                    </fo:block>
                </fo:flow>
        
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
</xsl:stylesheet>