<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : lst.order.xsl
    Created on : 03 July 2013, 16:38
    Author     : robur
    Description:
        Create list of orders for selected user.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html"/>

    <xsl:template match="/orderlist">
        <div id="order-list">
            <xsl:apply-templates select="order"/>
        </div>
    </xsl:template>
        
    <xsl:template match="order">
        <div class="order-row">
            sellcloudmusic id:<span>
                <xsl:value-of select = "id_order"/>
            </span>
            paypal transaction id:<span>
                <xsl:value-of select = "txn_id"/>
            </span>            
        </div>
        <div class="item-row">
                <xsl:apply-templates select="items"/>
        </div>
    </xsl:template>

    <xsl:template match="items">
        <ul class="item-list">
                <xsl:apply-templates select="item"/>
                <li class="item-list-row item-list-row-total">
                    Total:<span class="price">$<xsl:value-of select="sum(item/mc_gross_)"/></span>
                </li>                
        </ul>
    </xsl:template>
    
    <xsl:template match="item">
        <li class="item-list-row">
            <span>
                <xsl:value-of select = "item_name"/>
            </span>
            <span class="price">
                $<xsl:value-of select = "mc_gross_"/>
            </span>
        </li>    
    </xsl:template>
        
</xsl:stylesheet>
