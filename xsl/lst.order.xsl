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
            <span class="keys">
                sellcloudmusic id:
            </span>
            <span class="values">
                <xsl:value-of select = "id_order"/>
            </span>
            <span class="keys">
                paypal transaction id:
            </span>
            <span class="values">
                <xsl:value-of select = "txn_id"/>
            </span>
            <span class="keys">
                date and time:
            </span>
            <span class="values">
                <xsl:value-of select = "substring(timestamp,0,17)"/>
            </span>
        </div>
        <div class="pdf-generator" title="Download invoice as PDF">
                 <xsl:attribute name="data-id-order">
                    <xsl:value-of select="id_order"/>
                </xsl:attribute>
        </div>
        <div class="item-row">
            <xsl:apply-templates select="items"/>
        </div>
    </xsl:template>

    <xsl:template match="items">
        <table class="item-list">
            <xsl:apply-templates select="item"/>
            <tr class="item-list-row item-list-row-total">
                <td>Total:</td><td class="price">$<xsl:value-of select="format-number(sum(item/mc_gross_), '#.00')"/></td>
            </tr>
        </table>
    </xsl:template>
    
    <xsl:template match="item">
        <tr class="item-list-row">
            <td class= "name">
                <xsl:value-of select = "item_name"/>
            </td>
            <td class="price">
                $<xsl:value-of select = "format-number(mc_gross_, '#.00')"/>
            </td>
        </tr>
    </xsl:template>
        
</xsl:stylesheet>
