package com.bendpro.core

data class AngleConstants(
    val multiplier: Double,
    val shrinkPerInch: Double
)

val ANGLE_TABLE: Map<Double, AngleConstants> = mapOf(
    10.0 to AngleConstants(6.0, 1.0 / 16.0),
    22.5 to AngleConstants(2.6, 1.0 / 4.0),
    30.0 to AngleConstants(2.0, 3.0 / 8.0),
    45.0 to AngleConstants(1.4, 3.0 / 8.0),
    60.0 to AngleConstants(1.2, 1.0 / 4.0)
)

val OFFSET_ANGLES: List<Double> = listOf(10.0, 22.5, 30.0, 45.0, 60.0)

val DEDUCT_TABLE: Map<Double, Double> = mapOf(
    0.5 to 5.0,
    0.75 to 6.0,
    1.0 to 8.0,
    1.25 to 11.0,
    1.5 to 13.0,
    2.0 to 17.0
)

val TRADE_SIZES: List<Double> = listOf(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)

val TRADE_SIZE_LABELS: Map<Double, String> = mapOf(
    0.5 to "1/2\"",
    0.75 to "3/4\"",
    1.0 to "1\"",
    1.25 to "1-1/4\"",
    1.5 to "1-1/2\"",
    2.0 to "2\""
)

fun tradeSizeLabel(sizeIn: Double): String = TRADE_SIZE_LABELS[sizeIn] ?: "$sizeIn\""

val EMT_INTERNAL_AREA_SQIN: Map<Double, Double> = mapOf(
    0.5 to 0.304,
    0.75 to 0.533,
    1.0 to 0.864,
    1.25 to 1.496,
    1.5 to 2.036,
    2.0 to 3.356
)

val THHN_AREA_SQIN: Map<String, Double> = linkedMapOf(
    "14" to 0.0097,
    "12" to 0.0133,
    "10" to 0.0211,
    "8" to 0.0366,
    "6" to 0.0507,
    "4" to 0.0824,
    "3" to 0.0973,
    "2" to 0.1158,
    "1" to 0.1562
)

val WIRE_AWG_OPTIONS: List<String> = THHN_AREA_SQIN.keys.toList()

val BENDERS: List<Bender> = listOf(
    Bender(
        id = "klein-emt-standard",
        brand = "Klein Tools",
        model = "EMT Bender (1/2–1\")",
        conduitSizesIn = listOf(0.5, 0.75, 1.0),
        minShoeRadiusIn = mapOf(0.5 to 4.0, 0.75 to 4.5, 1.0 to 5.75)
    ),
    Bender(
        id = "greenlee-855",
        brand = "Greenlee",
        model = "855 Series (1/2–1-1/4\")",
        conduitSizesIn = listOf(0.5, 0.75, 1.0, 1.25),
        minShoeRadiusIn = mapOf(0.5 to 4.0, 0.75 to 4.5, 1.0 to 5.75, 1.25 to 7.0)
    ),
    Bender(
        id = "milwaukee-emt",
        brand = "Milwaukee",
        model = "EMT Bender (1/2–1\")",
        conduitSizesIn = listOf(0.5, 0.75, 1.0),
        minShoeRadiusIn = mapOf(0.5 to 4.0, 0.75 to 4.5, 1.0 to 5.75)
    ),
    Bender(
        id = "ideal-imc-rigid",
        brand = "Ideal Industries",
        model = "IMC/Rigid Bender (1/2–1\")",
        conduitSizesIn = listOf(0.5, 0.75, 1.0),
        minShoeRadiusIn = mapOf(0.5 to 4.5, 0.75 to 5.25, 1.0 to 6.5)
    ),
    Bender(
        id = "ridgid-emt",
        brand = "Ridgid",
        model = "EMT Bender (1/2–1\")",
        conduitSizesIn = listOf(0.5, 0.75, 1.0),
        minShoeRadiusIn = mapOf(0.5 to 4.0, 0.75 to 4.5, 1.0 to 5.75)
    ),
    Bender(
        id = "itoolco-mega-1-1.5",
        brand = "iToolco",
        model = "Mega Bender (1–1-1/2\")",
        conduitSizesIn = listOf(1.0, 1.25, 1.5),
        minShoeRadiusIn = mapOf(1.0 to 5.75, 1.25 to 7.0, 1.5 to 8.25)
    ),
    Bender(
        id = "current-tools-1000",
        brand = "Current Tools",
        model = "1000 Series (1/2–1\")",
        conduitSizesIn = listOf(0.5, 0.75, 1.0),
        minShoeRadiusIn = mapOf(0.5 to 4.0, 0.75 to 4.5, 1.0 to 5.75)
    ),
    Bender(
        id = "custom",
        brand = "Custom",
        model = "Add your own",
        conduitSizesIn = listOf(0.5, 0.75, 1.0, 1.25, 1.5, 2.0),
        minShoeRadiusIn = mapOf(0.5 to 4.0, 0.75 to 4.5, 1.0 to 5.75, 1.25 to 7.0, 1.5 to 8.25, 2.0 to 9.5)
    )
)

fun shoeRadius(bender: Bender, tradeSizeIn: Double): Double =
    bender.minShoeRadiusIn[tradeSizeIn] ?: 4.0
