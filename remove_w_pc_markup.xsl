<?xml version="1.0" encoding="UTF-8"?>
<!-- remove the rich lingustic annotations/tokenization of shakedracor -->
<!-- based on: https://github.com/dracor-org/epdracor/blob/main/ep2dracor.xsl by Carsten Milling-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:ep="http://earlyprint.org/ns/1.0"
    xmlns:d="http://dracor.org/ns/1.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="ep d tei fn map" version="3.0">

    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="spelling">reg</xsl:param>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="ep:get-content">
        <xsl:param name="w"/>
        <xsl:choose>
            <xsl:when test="$spelling = 'orig'">
                <xsl:choose>
                    <xsl:when test="$w/@orig">
                        <xsl:value-of select="$w/@orig"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$w"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$spelling = 'w'">
                <xsl:value-of select="$w"/>
            </xsl:when>
            <xsl:when test="$spelling = 'reg'">
                <xsl:choose>
                    <xsl:when test="$w/@reg">
                        <xsl:value-of select="$w/@reg"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$w"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$spelling = 'lemma'">
                <xsl:choose>
                    <xsl:when test="$w/@lemma">
                        <xsl:value-of select="$w/@lemma"/>
                    </xsl:when>
                    <xsl:when test="$w/@reg">
                        <xsl:value-of select="$w/@reg"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$w"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="tei:w">
        <xsl:variable name="content">
            <xsl:value-of select="ep:get-content(.)"/>
        </xsl:variable>
        <xsl:value-of select="$content"/>
        <xsl:if
            test="
                (not(@join) or (@join ne 'right')) and
                (not(following::*[1][name() = 'pc' and not(@join)])) and
                (not(following::*[1][@join = 'left']))">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:pc">
        <xsl:value-of select="text()"/>
        <xsl:if
            test="
                (not(@join) or (@join ne 'right')) and
                (not(following::*[1][name() = 'pc' and not(@join)])) and
                (not(following::*[1][@join = 'left']))">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:c">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="tei:*[tei:w or tei:pc]">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
        </xsl:copy>
    </xsl:template>




</xsl:stylesheet>
