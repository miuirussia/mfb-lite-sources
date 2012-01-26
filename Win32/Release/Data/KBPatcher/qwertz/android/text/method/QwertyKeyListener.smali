.class public Landroid/text/method/QwertyKeyListener;
.super Landroid/text/method/BaseKeyListener;
.source "QwertyKeyListener.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Landroid/text/method/QwertyKeyListener$Replaced;
    }
.end annotation


# static fields
.field private static PICKER_SETS:Landroid/util/SparseArray;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Landroid/util/SparseArray",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private static bIsReplaced:Z

.field private static bIsRussian:Z

.field private static iLastKeycode:I

.field private static iLastPressTime:J

.field private static sInstance:[Landroid/text/method/QwertyKeyListener;


# instance fields
.field private mAutoCap:Landroid/text/method/TextKeyListener$Capitalize;

.field private mAutoText:Z


# direct methods
.method static constructor <clinit>()V
    .registers 3

    .prologue
    .line 32
    const/4 v0, -0x1

    sput v0, Landroid/text/method/QwertyKeyListener;->iLastKeycode:I

    const-wide/16 v0, 0x0

    sput-wide v0, Landroid/text/method/QwertyKeyListener;->iLastPressTime:J

    const/4 v0, 0x0

    sput-boolean v0, Landroid/text/method/QwertyKeyListener;->bIsRussian:Z

    invoke-static {}, Landroid/text/method/TextKeyListener$Capitalize;->values()[Landroid/text/method/TextKeyListener$Capitalize;

    move-result-object v0

    array-length v0, v0

    mul-int/lit8 v0, v0, 0x2

    new-array v0, v0, [Landroid/text/method/QwertyKeyListener;

    sput-object v0, Landroid/text/method/QwertyKeyListener;->sInstance:[Landroid/text/method/QwertyKeyListener;

    .line 401
    new-instance v0, Landroid/util/SparseArray;

    invoke-direct {v0}, Landroid/util/SparseArray;-><init>()V

    sput-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    .line 404
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x41

    const-string/jumbo v2, "\u00c0\u00c1\u00c2\u00c4\u00c6\u00c3\u00c5\u0104\u0100"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 405
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x43

    const-string/jumbo v2, "\u00c7\u0106\u010c"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 406
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x44

    const-string/jumbo v2, "\u010e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 407
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x45

    const-string/jumbo v2, "\u00c8\u00c9\u00ca\u00cb\u0118\u011a\u0112"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 408
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x47

    const-string/jumbo v2, "\u011e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 409
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x4c

    const-string/jumbo v2, "\u0141"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 410
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x49

    const-string/jumbo v2, "\u00cc\u00cd\u00ce\u00cf\u012a\u0130"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 411
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x4e

    const-string/jumbo v2, "\u00d1\u0143\u0147"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 412
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x4f

    const-string/jumbo v2, "\u00d8\u0152\u00d5\u00d2\u00d3\u00d4\u00d6\u014c"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 413
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x52

    const-string/jumbo v2, "\u0158"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 414
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x53

    const-string/jumbo v2, "\u015a\u0160\u015e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 415
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x54

    const-string/jumbo v2, "\u0164"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 416
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x55

    const-string/jumbo v2, "\u00d9\u00da\u00db\u00dc\u016e\u016a"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 417
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x59

    const-string/jumbo v2, "\u00dd\u0178"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 418
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x5a

    const-string/jumbo v2, "\u0179\u017b\u017d"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 419
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x61

    const-string/jumbo v2, "\u00e0\u00e1\u00e2\u00e4\u00e6\u00e3\u00e5\u0105\u0101"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 420
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x63

    const-string/jumbo v2, "\u00e7\u0107\u010d"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 421
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x64

    const-string/jumbo v2, "\u010f"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 422
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x65

    const-string/jumbo v2, "\u00e8\u00e9\u00ea\u00eb\u0119\u011b\u0113"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 423
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x67

    const-string/jumbo v2, "\u011f"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 424
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x69

    const-string/jumbo v2, "\u00ec\u00ed\u00ee\u00ef\u012b\u0131"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 425
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x6c

    const-string/jumbo v2, "\u0142"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 426
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x6e

    const-string/jumbo v2, "\u00f1\u0144\u0148"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 427
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x6f

    const-string/jumbo v2, "\u00f8\u0153\u00f5\u00f2\u00f3\u00f4\u00f6\u014d"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 428
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x72

    const-string/jumbo v2, "\u0159"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 429
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x73

    const-string/jumbo v2, "\u00a7\u00df\u015b\u0161\u015f"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 430
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x74

    const-string/jumbo v2, "\u0165"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 431
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x75

    const-string/jumbo v2, "\u00f9\u00fa\u00fb\u00fc\u016f\u016b"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 432
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x79

    const-string/jumbo v2, "\u00fd\u00ff"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 433
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x7a

    const-string/jumbo v2, "\u017a\u017c\u017e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 434
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const v1, 0xef01

    const-string/jumbo v2, "\u2026\u00a5\u2022\u00ae\u00a9\u00b1[]{}\u00b0`^\\|\u2116\u2122\u20a4\u20ac$\u222b\u2126\u2264\u2265"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 436
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x2f

    const-string v2, "\\"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 440
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x31

    const-string/jumbo v2, "\u00b9\u00bd\u2153\u00bc\u215b"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 441
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x32

    const-string/jumbo v2, "\u00b2\u2154"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 442
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x33

    const-string/jumbo v2, "\u00b3\u00be\u215c"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 443
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x34

    const-string/jumbo v2, "\u2074"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 444
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x35

    const-string/jumbo v2, "\u215d"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 445
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x37

    const-string/jumbo v2, "\u215e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 446
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x30

    const-string/jumbo v2, "\u207f\u2205"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 447
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x24

    const-string/jumbo v2, "\u00a2\u00a3\u20ac\u00a5\u20a3\u20a4\u20b1"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 448
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x25

    const-string/jumbo v2, "\u2030"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 449
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x2a

    const-string/jumbo v2, "\u2020\u2021"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 450
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x2d

    const-string/jumbo v2, "\u2013\u2014"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 451
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x2b

    const-string/jumbo v2, "\u00b1"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 452
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x28

    const-string v2, "[{<"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 453
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x29

    const-string v2, "]}>"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 454
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x21

    const-string/jumbo v2, "\u00a1"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 455
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x22

    const-string/jumbo v2, "\u201c\u201d\u00ab\u00bb\u02dd"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 456
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x3f

    const-string/jumbo v2, "\u00bf"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 457
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x2c

    const-string/jumbo v2, "\u201a\u201e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 461
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x3d

    const-string/jumbo v2, "\u2260\u2248\u221e"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 462
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x3c

    const-string/jumbo v2, "\u2264\u00ab\u2039"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 463
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    const/16 v1, 0x3e

    const-string/jumbo v2, "\u2265\u00bb\u203a"

    invoke-virtual {v0, v1, v2}, Landroid/util/SparseArray;->put(ILjava/lang/Object;)V

    .line 464
    return-void
.end method

.method public constructor <init>(Landroid/text/method/TextKeyListener$Capitalize;Z)V
    .registers 5
    .parameter "cap"
    .parameter "autotext"

    .prologue
    .line 35
    invoke-direct {p0}, Landroid/text/method/BaseKeyListener;-><init>()V

    const-string v1, "hw.keyboards.2000.devname"

    invoke-static {v1}, Landroid/os/SystemProperties;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 47
    .local v0, tag:Ljava/lang/String;
    if-eqz v0, :cond_13

    .line 48
    const-string v1, "russian"

    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    sput-boolean v1, Landroid/text/method/QwertyKeyListener;->bIsRussian:Z

    .line 36
    :cond_13
    iput-object p1, p0, Landroid/text/method/QwertyKeyListener;->mAutoCap:Landroid/text/method/TextKeyListener$Capitalize;

    .line 37
    iput-boolean p2, p0, Landroid/text/method/QwertyKeyListener;->mAutoText:Z

    .line 38
    return-void
.end method

.method private checkAndModifyKeycode(II)I
    .registers 4

    sparse-switch p1, :sswitch_data_1c

    move v0, p2

    :goto_4
    return v0

    :sswitch_5
    const/16 v0, 0x44c

    goto :goto_4

    :sswitch_8
    const/16 v0, 0x451

    goto :goto_4

    :sswitch_b
    const/16 v0, 0x44d

    goto :goto_4

    :sswitch_e
    const/16 v0, 0x44a

    goto :goto_4

    :sswitch_11
    const/16 v0, 0x44e

    goto :goto_4

    :sswitch_14
    const/16 v0, 0x449

    goto :goto_4

    :sswitch_17
    const/16 v0, 0x448

    goto :goto_4

    nop

    nop

    :sswitch_data_1c
    .sparse-switch
        0x21 -> :sswitch_b
        0x26 -> :sswitch_5
        0x2b -> :sswitch_8
        0x31 -> :sswitch_11
        0x32 -> :sswitch_17
        0x33 -> :sswitch_14
        0x35 -> :sswitch_e
    .end sparse-switch
.end method

.method public static getInstance(ZLandroid/text/method/TextKeyListener$Capitalize;)Landroid/text/method/QwertyKeyListener;
    .registers 5
    .parameter "autotext"
    .parameter "cap"

    .prologue
    .line 46
    invoke-virtual {p1}, Landroid/text/method/TextKeyListener$Capitalize;->ordinal()I

    move-result v1

    mul-int/lit8 v1, v1, 0x2

    if-eqz p0, :cond_1f

    const/4 v2, 0x1

    :goto_9
    add-int v0, v1, v2

    .line 48
    .local v0, off:I
    sget-object v1, Landroid/text/method/QwertyKeyListener;->sInstance:[Landroid/text/method/QwertyKeyListener;

    aget-object v1, v1, v0

    if-nez v1, :cond_1a

    .line 49
    sget-object v1, Landroid/text/method/QwertyKeyListener;->sInstance:[Landroid/text/method/QwertyKeyListener;

    new-instance v2, Landroid/text/method/QwertyKeyListener;

    invoke-direct {v2, p1, p0}, Landroid/text/method/QwertyKeyListener;-><init>(Landroid/text/method/TextKeyListener$Capitalize;Z)V

    aput-object v2, v1, v0

    .line 52
    :cond_1a
    sget-object v1, Landroid/text/method/QwertyKeyListener;->sInstance:[Landroid/text/method/QwertyKeyListener;

    aget-object v1, v1, v0

    return-object v1

    .line 46
    .end local v0           #off:I
    :cond_1f
    const/4 v2, 0x0

    goto :goto_9
.end method

.method private getReplacement(Ljava/lang/CharSequence;IILandroid/view/View;)Ljava/lang/String;
    .registers 15
    .parameter "src"
    .parameter "start"
    .parameter "end"
    .parameter "view"

    .prologue
    const/4 v9, 0x0

    const/4 v8, 0x0

    .line 332
    sub-int v4, p3, p2

    .line 333
    .local v4, len:I
    const/4 v1, 0x0

    .line 335
    .local v1, changecase:Z
    invoke-static {p1, p2, p3, p4}, Landroid/text/AutoText;->get(Ljava/lang/CharSequence;IILandroid/view/View;)Ljava/lang/String;

    move-result-object v6

    .line 337
    .local v6, replacement:Ljava/lang/String;
    if-nez v6, :cond_1e

    .line 338
    invoke-static {p1, p2, p3}, Landroid/text/TextUtils;->substring(Ljava/lang/CharSequence;II)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v3

    .line 339
    .local v3, key:Ljava/lang/String;
    sub-int v7, p3, p2

    invoke-static {v3, v8, v7, p4}, Landroid/text/AutoText;->get(Ljava/lang/CharSequence;IILandroid/view/View;)Ljava/lang/String;

    move-result-object v6

    .line 340
    const/4 v1, 0x1

    .line 342
    if-nez v6, :cond_1e

    move-object v7, v9

    .line 370
    .end local v3           #key:Ljava/lang/String;
    :goto_1d
    return-object v7

    .line 346
    :cond_1e
    const/4 v0, 0x0

    .line 348
    .local v0, caps:I
    if-eqz v1, :cond_33

    .line 349
    move v2, p2

    .local v2, j:I
    :goto_22
    if-ge v2, p3, :cond_33

    .line 350
    invoke-interface {p1, v2}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v7

    invoke-static {v7}, Ljava/lang/Character;->isUpperCase(C)Z

    move-result v7

    if-eqz v7, :cond_30

    .line 351
    add-int/lit8 v0, v0, 0x1

    .line 349
    :cond_30
    add-int/lit8 v2, v2, 0x1

    goto :goto_22

    .line 357
    .end local v2           #j:I
    :cond_33
    if-nez v0, :cond_44

    .line 358
    move-object v5, v6

    .line 366
    .local v5, out:Ljava/lang/String;
    :goto_36
    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v7

    if-ne v7, v4, :cond_58

    invoke-static {p1, p2, v5, v8, v4}, Landroid/text/TextUtils;->regionMatches(Ljava/lang/CharSequence;ILjava/lang/CharSequence;II)Z

    move-result v7

    if-eqz v7, :cond_58

    move-object v7, v9

    .line 368
    goto :goto_1d

    .line 359
    .end local v5           #out:Ljava/lang/String;
    :cond_44
    const/4 v7, 0x1

    if-ne v0, v7, :cond_4c

    .line 360
    invoke-static {v6}, Landroid/text/method/QwertyKeyListener;->toTitleCase(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .restart local v5       #out:Ljava/lang/String;
    goto :goto_36

    .line 361
    .end local v5           #out:Ljava/lang/String;
    :cond_4c
    if-ne v0, v4, :cond_53

    .line 362
    invoke-virtual {v6}, Ljava/lang/String;->toUpperCase()Ljava/lang/String;

    move-result-object v5

    .restart local v5       #out:Ljava/lang/String;
    goto :goto_36

    .line 364
    .end local v5           #out:Ljava/lang/String;
    :cond_53
    invoke-static {v6}, Landroid/text/method/QwertyKeyListener;->toTitleCase(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .restart local v5       #out:Ljava/lang/String;
    goto :goto_36

    :cond_58
    move-object v7, v5

    .line 370
    goto :goto_1d
.end method

.method public static markAsReplaced(Landroid/text/Spannable;IILjava/lang/String;)V
    .registers 11
    .parameter "content"
    .parameter "start"
    .parameter "end"
    .parameter "original"

    .prologue
    const/4 v6, 0x0

    .line 388
    invoke-interface {p0}, Landroid/text/Spannable;->length()I

    move-result v4

    const-class v5, Landroid/text/method/QwertyKeyListener$Replaced;

    invoke-interface {p0, v6, v4, v5}, Landroid/text/Spannable;->getSpans(IILjava/lang/Class;)[Ljava/lang/Object;

    move-result-object v3

    check-cast v3, [Landroid/text/method/QwertyKeyListener$Replaced;

    .line 389
    .local v3, repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    const/4 v0, 0x0

    .local v0, a:I
    :goto_e
    array-length v4, v3

    if-ge v0, v4, :cond_19

    .line 390
    aget-object v4, v3, v0

    invoke-interface {p0, v4}, Landroid/text/Spannable;->removeSpan(Ljava/lang/Object;)V

    .line 389
    add-int/lit8 v0, v0, 0x1

    goto :goto_e

    .line 393
    :cond_19
    invoke-virtual {p3}, Ljava/lang/String;->length()I

    move-result v1

    .line 394
    .local v1, len:I
    new-array v2, v1, [C

    .line 395
    .local v2, orig:[C
    invoke-virtual {p3, v6, v1, v2, v6}, Ljava/lang/String;->getChars(II[CI)V

    .line 397
    new-instance v4, Landroid/text/method/QwertyKeyListener$Replaced;

    invoke-direct {v4, v2}, Landroid/text/method/QwertyKeyListener$Replaced;-><init>([C)V

    const/16 v5, 0x21

    invoke-interface {p0, v4, p1, p2, v5}, Landroid/text/Spannable;->setSpan(Ljava/lang/Object;III)V

    .line 399
    return-void
.end method

.method private showCharacterPicker(Landroid/view/View;Landroid/text/Editable;CZI)Z
    .registers 13
    .parameter "view"
    .parameter "content"
    .parameter "c"
    .parameter "insert"
    .parameter "count"

    .prologue
    const/4 v6, 0x1

    .line 468
    sget-object v0, Landroid/text/method/QwertyKeyListener;->PICKER_SETS:Landroid/util/SparseArray;

    invoke-virtual {v0, p3}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 469
    .local v4, set:Ljava/lang/String;
    if-nez v4, :cond_d

    .line 470
    const/4 v0, 0x0

    .line 478
    :goto_c
    return v0

    .line 473
    :cond_d
    if-ne p5, v6, :cond_1e

    .line 474
    new-instance v0, Landroid/text/method/CharacterPickerDialog;

    invoke-virtual {p1}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    move-object v2, p1

    move-object v3, p2

    move v5, p4

    invoke-direct/range {v0 .. v5}, Landroid/text/method/CharacterPickerDialog;-><init>(Landroid/content/Context;Landroid/view/View;Landroid/text/Editable;Ljava/lang/String;Z)V

    invoke-virtual {v0}, Landroid/text/method/CharacterPickerDialog;->show()V

    :cond_1e
    move v0, v6

    .line 478
    goto :goto_c
.end method

.method private static toTitleCase(Ljava/lang/String;)Ljava/lang/String;
    .registers 3
    .parameter "src"

    .prologue
    .line 482
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v1, 0x0

    invoke-virtual {p0, v1}, Ljava/lang/String;->charAt(I)C

    move-result v1

    invoke-static {v1}, Ljava/lang/Character;->toUpperCase(C)C

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {p0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method


# virtual methods
.method public getInputType()I
    .registers 3

    .prologue
    .line 56
    iget-object v0, p0, Landroid/text/method/QwertyKeyListener;->mAutoCap:Landroid/text/method/TextKeyListener$Capitalize;

    iget-boolean v1, p0, Landroid/text/method/QwertyKeyListener;->mAutoText:Z

    invoke-static {v0, v1}, Landroid/text/method/QwertyKeyListener;->makeTextContentType(Landroid/text/method/TextKeyListener$Capitalize;Z)I

    move-result v0

    return v0
.end method

.method public onKeyDown(Landroid/view/View;Landroid/text/Editable;ILandroid/view/KeyEvent;)Z
    .registers 51
    .parameter "view"
    .parameter "content"
    .parameter "keyCode"
    .parameter "event"

    .prologue
    .line 94
    const/16 v35, 0x0

    .line 96
    .local v35, pref:I
    invoke-virtual/range {p4 .. p4}, Landroid/view/KeyEvent;->isInitToggler()Z

    move-result v5

    if-nez v5, :cond_14

    if-eqz p1, :cond_14

    .line 97
    invoke-virtual/range {p1 .. p1}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v5

    move-object/from16 v0, p4

    move-object v1, v5

    invoke-virtual {v0, v1}, Landroid/view/KeyEvent;->initToggler(Landroid/content/Context;)V

    .line 100
    :cond_14
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->getMetaState(Ljava/lang/CharSequence;)I

    move-result v5

    move-object/from16 v0, p4

    move v1, v5

    invoke-virtual {v0, v1}, Landroid/view/KeyEvent;->getUnicodeChar(I)I

    move-result v29

    .line 102
    .local v29, i:I
    move/from16 v0, v29

    and-int/lit16 v0, v0, 0xf00

    move v5, v0

    const/16 v6, 0x400

    if-eq v5, v6, :cond_39

    const/16 v5, 0x2e

    move/from16 v0, v29

    move v1, v5

    if-ne v0, v1, :cond_118

    invoke-virtual/range {p4 .. p4}, Landroid/view/KeyEvent;->isToggled()Z

    move-result v5

    if-eqz v5, :cond_118

    sget-boolean v5, Landroid/text/method/QwertyKeyListener;->bIsRussian:Z

    if-eqz v5, :cond_118

    :cond_39
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v5

    sget-wide v7, Landroid/text/method/QwertyKeyListener;->iLastPressTime:J

    sub-long/2addr v5, v7

    const-wide/16 v7, 0x1f4

    cmp-long v5, v5, v7

    if-gez v5, :cond_118

    sget v5, Landroid/text/method/QwertyKeyListener;->iLastKeycode:I

    move/from16 v0, p3

    move v1, v5

    if-ne v0, v1, :cond_118

    sget-boolean v5, Landroid/text/method/QwertyKeyListener;->bIsReplaced:Z

    if-nez v5, :cond_118

    .line 107
    move/from16 v32, v29

    .line 108
    .local v32, oldChar:I
    const/4 v5, 0x1

    sput-boolean v5, Landroid/text/method/QwertyKeyListener;->bIsReplaced:Z

    .line 109
    invoke-static/range {p2 .. p2}, Landroid/text/Selection;->getSelectionEnd(Ljava/lang/CharSequence;)I

    move-result v39

    .line 111
    .local v39, sel:I
    move-object/from16 v0, p0

    move/from16 v1, p3

    move/from16 v2, v32

    invoke-direct {v0, v1, v2}, Landroid/text/method/QwertyKeyListener;->checkAndModifyKeycode(II)I

    move-result v29

    .line 112
    if-lez v39, :cond_7a

    const/4 v5, 0x1

    sub-int v5, v39, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v5

    invoke-static {v5}, Ljava/lang/Character;->isUpperCase(C)Z

    move-result v5

    if-eqz v5, :cond_7a

    .line 113
    invoke-static/range {v29 .. v29}, Ljava/lang/Character;->toUpperCase(I)I

    move-result v29

    .line 116
    :cond_7a
    if-lez v39, :cond_90

    move/from16 v0, v32

    move/from16 v1, v29

    if-eq v0, v1, :cond_90

    .line 117
    const/4 v5, 0x1

    sub-int v5, v39, v5

    const-string v6, ""

    move-object/from16 v0, p2

    move v1, v5

    move/from16 v2, v39

    move-object v3, v6

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 123
    .end local v32           #oldChar:I
    .end local v39           #sel:I
    :cond_90
    :goto_90
    sput p3, Landroid/text/method/QwertyKeyListener;->iLastKeycode:I

    .line 124
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v5

    sput-wide v5, Landroid/text/method/QwertyKeyListener;->iLastPressTime:J

    .line 126
    if-eqz p1, :cond_a6

    .line 127
    invoke-static {}, Landroid/text/method/TextKeyListener;->getInstance()Landroid/text/method/TextKeyListener;

    move-result-object v5

    invoke-virtual/range {p1 .. p1}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/text/method/TextKeyListener;->getPrefs(Landroid/content/Context;)I

    move-result v35

    .line 131
    :cond_a6
    invoke-static/range {p2 .. p2}, Landroid/text/Selection;->getSelectionStart(Ljava/lang/CharSequence;)I

    move-result v17

    .line 132
    .local v17, a:I
    invoke-static/range {p2 .. p2}, Landroid/text/Selection;->getSelectionEnd(Ljava/lang/CharSequence;)I

    move-result v21

    .line 134
    .local v21, b:I
    move/from16 v0, v17

    move/from16 v1, v21

    invoke-static {v0, v1}, Ljava/lang/Math;->min(II)I

    move-result v41

    .line 135
    .local v41, selStart:I
    move/from16 v0, v17

    move/from16 v1, v21

    invoke-static {v0, v1}, Ljava/lang/Math;->max(II)I

    move-result v40

    .line 137
    .local v40, selEnd:I
    if-ltz v41, :cond_c2

    if-gez v40, :cond_cf

    .line 138
    :cond_c2
    const/16 v40, 0x0

    move/from16 v41, v40

    .line 139
    const/4 v5, 0x0

    const/4 v6, 0x0

    move-object/from16 v0, p2

    move v1, v5

    move v2, v6

    invoke-static {v0, v1, v2}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;II)V

    .line 143
    :cond_cf
    sget-object v5, Landroid/text/method/TextKeyListener;->ACTIVE:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanStart(Ljava/lang/Object;)I

    move-result v20

    .line 144
    .local v20, activeStart:I
    sget-object v5, Landroid/text/method/TextKeyListener;->ACTIVE:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanEnd(Ljava/lang/Object;)I

    move-result v19

    .line 150
    .local v19, activeEnd:I
    invoke-virtual/range {p4 .. p4}, Landroid/view/KeyEvent;->getRepeatCount()I

    move-result v10

    .line 151
    .local v10, count:I
    if-lez v10, :cond_11d

    move/from16 v0, v41

    move/from16 v1, v40

    if-ne v0, v1, :cond_11d

    if-lez v41, :cond_11d

    .line 152
    const/4 v5, 0x1

    sub-int v5, v41, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v8

    .line 154
    .local v8, c:C
    move v0, v8

    move/from16 v1, v29

    if-eq v0, v1, :cond_106

    invoke-static/range {v29 .. v29}, Ljava/lang/Character;->toUpperCase(I)I

    move-result v5

    if-ne v8, v5, :cond_11d

    if-eqz p1, :cond_11d

    .line 155
    :cond_106
    const/4 v9, 0x0

    move-object/from16 v5, p0

    move-object/from16 v6, p1

    move-object/from16 v7, p2

    invoke-direct/range {v5 .. v10}, Landroid/text/method/QwertyKeyListener;->showCharacterPicker(Landroid/view/View;Landroid/text/Editable;CZI)Z

    move-result v5

    if-eqz v5, :cond_11d

    .line 156
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->resetMetaState(Landroid/text/Spannable;)V

    .line 157
    const/4 v5, 0x1

    .line 398
    .end local v8           #c:C
    :goto_117
    return v5

    .line 120
    .end local v10           #count:I
    .end local v17           #a:I
    .end local v19           #activeEnd:I
    .end local v20           #activeStart:I
    .end local v21           #b:I
    .end local v40           #selEnd:I
    .end local v41           #selStart:I
    :cond_118
    const/4 v5, 0x0

    sput-boolean v5, Landroid/text/method/QwertyKeyListener;->bIsReplaced:Z

    goto/16 :goto_90

    .line 162
    .restart local v10       #count:I
    .restart local v17       #a:I
    .restart local v19       #activeEnd:I
    .restart local v20       #activeStart:I
    .restart local v21       #b:I
    .restart local v40       #selEnd:I
    .restart local v41       #selStart:I
    :cond_11d
    const v5, 0xef01

    move/from16 v0, v29

    move v1, v5

    if-ne v0, v1, :cond_13b

    .line 163
    if-eqz p1, :cond_136

    .line 164
    const v14, 0xef01

    const/4 v15, 0x1

    const/16 v16, 0x1

    move-object/from16 v11, p0

    move-object/from16 v12, p1

    move-object/from16 v13, p2

    invoke-direct/range {v11 .. v16}, Landroid/text/method/QwertyKeyListener;->showCharacterPicker(Landroid/view/View;Landroid/text/Editable;CZI)Z

    .line 167
    :cond_136
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->resetMetaState(Landroid/text/Spannable;)V

    .line 168
    const/4 v5, 0x1

    goto :goto_117

    .line 171
    :cond_13b
    const v5, 0xef04

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_14b

    const v5, 0xef03

    move/from16 v0, v29

    move v1, v5

    if-ne v0, v1, :cond_161

    .line 172
    :cond_14b
    if-nez v41, :cond_15e

    const-string v5, "www."

    :goto_14f
    move-object/from16 v0, p2

    move/from16 v1, v41

    move/from16 v2, v40

    move-object v3, v5

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 173
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->adjustMetaAfterKeypress(Landroid/text/Spannable;)V

    .line 174
    const/4 v5, 0x1

    goto :goto_117

    .line 172
    :cond_15e
    const-string v5, ".com"

    goto :goto_14f

    .line 177
    :cond_161
    const v5, 0xef00

    move/from16 v0, v29

    move v1, v5

    if-ne v0, v1, :cond_1b3

    .line 180
    move/from16 v0, v41

    move/from16 v1, v40

    if-ne v0, v1, :cond_18d

    .line 181
    move/from16 v43, v40

    .line 184
    .local v43, start:I
    :goto_171
    if-lez v43, :cond_18f

    sub-int v5, v40, v43

    const/4 v6, 0x4

    if-ge v5, v6, :cond_18f

    const/4 v5, 0x1

    sub-int v5, v43, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v5

    const/16 v6, 0x10

    invoke-static {v5, v6}, Ljava/lang/Character;->digit(CI)I

    move-result v5

    if-ltz v5, :cond_18f

    .line 185
    add-int/lit8 v43, v43, -0x1

    goto :goto_171

    .line 188
    .end local v43           #start:I
    :cond_18d
    move/from16 v43, v41

    .line 191
    .restart local v43       #start:I
    :cond_18f
    const/16 v22, -0x1

    .line 193
    .local v22, ch:I
    :try_start_191
    move-object/from16 v0, p2

    move/from16 v1, v43

    move/from16 v2, v40

    invoke-static {v0, v1, v2}, Landroid/text/TextUtils;->substring(Ljava/lang/CharSequence;II)Ljava/lang/String;

    move-result-object v28

    .line 194
    .local v28, hex:Ljava/lang/String;
    const/16 v5, 0x10

    move-object/from16 v0, v28

    move v1, v5

    invoke-static {v0, v1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;I)I
    :try_end_1a3
    .catch Ljava/lang/NumberFormatException; {:try_start_191 .. :try_end_1a3} :catch_52b

    move-result v22

    .line 197
    .end local v28           #hex:Ljava/lang/String;
    :goto_1a4
    if-ltz v22, :cond_35c

    .line 198
    move/from16 v41, v43

    .line 199
    move-object/from16 v0, p2

    move/from16 v1, v41

    move/from16 v2, v40

    invoke-static {v0, v1, v2}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;II)V

    .line 200
    move/from16 v29, v22

    .line 206
    .end local v22           #ch:I
    .end local v43           #start:I
    :cond_1b3
    :goto_1b3
    if-eqz v29, :cond_43a

    .line 207
    const/16 v25, 0x0

    .line 209
    .local v25, dead:Z
    const/high16 v5, -0x8000

    and-int v5, v5, v29

    if-eqz v5, :cond_1c4

    .line 210
    const/16 v25, 0x1

    .line 211
    const v5, 0x7fffffff

    and-int v29, v29, v5

    .line 214
    :cond_1c4
    move/from16 v0, v20

    move/from16 v1, v41

    if-ne v0, v1, :cond_201

    move/from16 v0, v19

    move/from16 v1, v40

    if-ne v0, v1, :cond_201

    .line 215
    const/16 v38, 0x0

    .line 217
    .local v38, replace:Z
    sub-int v5, v40, v41

    const/4 v6, 0x1

    sub-int/2addr v5, v6

    if-nez v5, :cond_1ee

    .line 218
    move-object/from16 v0, p2

    move/from16 v1, v41

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v18

    .line 219
    .local v18, accent:C
    move/from16 v0, v18

    move/from16 v1, v29

    invoke-static {v0, v1}, Landroid/view/KeyEvent;->getDeadChar(II)I

    move-result v23

    .line 221
    .local v23, composed:I
    if-eqz v23, :cond_1ee

    .line 222
    move/from16 v29, v23

    .line 223
    const/16 v38, 0x1

    .line 227
    .end local v18           #accent:C
    .end local v23           #composed:I
    :cond_1ee
    if-nez v38, :cond_201

    .line 228
    move-object/from16 v0, p2

    move/from16 v1, v40

    invoke-static {v0, v1}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;I)V

    .line 229
    sget-object v5, Landroid/text/method/TextKeyListener;->ACTIVE:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    .line 230
    move/from16 v41, v40

    .line 234
    .end local v38           #replace:Z
    :cond_201
    and-int/lit8 v5, v35, 0x1

    if-eqz v5, :cond_246

    invoke-static/range {v29 .. v29}, Ljava/lang/Character;->isLowerCase(I)Z

    move-result v5

    if-eqz v5, :cond_246

    move-object/from16 v0, p0

    iget-object v0, v0, Landroid/text/method/QwertyKeyListener;->mAutoCap:Landroid/text/method/TextKeyListener$Capitalize;

    move-object v5, v0

    move-object v0, v5

    move-object/from16 v1, p2

    move/from16 v2, v41

    invoke-static {v0, v1, v2}, Landroid/text/method/TextKeyListener;->shouldCap(Landroid/text/method/TextKeyListener$Capitalize;Ljava/lang/CharSequence;I)Z

    move-result v5

    if-eqz v5, :cond_246

    .line 237
    sget-object v5, Landroid/text/method/TextKeyListener;->CAPPED:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanEnd(Ljava/lang/Object;)I

    move-result v44

    .line 238
    .local v44, where:I
    sget-object v5, Landroid/text/method/TextKeyListener;->CAPPED:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanFlags(Ljava/lang/Object;)I

    move-result v27

    .line 240
    .local v27, flags:I
    move/from16 v0, v44

    move/from16 v1, v41

    if-ne v0, v1, :cond_360

    shr-int/lit8 v5, v27, 0x10

    const v6, 0xffff

    and-int/2addr v5, v6

    move v0, v5

    move/from16 v1, v29

    if-ne v0, v1, :cond_360

    .line 241
    sget-object v5, Landroid/text/method/TextKeyListener;->CAPPED:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    .line 257
    .end local v27           #flags:I
    .end local v44           #where:I
    :cond_246
    :goto_246
    move/from16 v0, v41

    move/from16 v1, v40

    if-eq v0, v1, :cond_253

    .line 258
    move-object/from16 v0, p2

    move/from16 v1, v40

    invoke-static {v0, v1}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;I)V

    .line 260
    :cond_253
    sget-object v5, Landroid/text/method/QwertyKeyListener;->OLD_SEL_START:Ljava/lang/Object;

    const/16 v6, 0x11

    move-object/from16 v0, p2

    move-object v1, v5

    move/from16 v2, v41

    move/from16 v3, v41

    move v4, v6

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    .line 263
    move/from16 v0, v29

    int-to-char v0, v0

    move v5, v0

    invoke-static {v5}, Ljava/lang/String;->valueOf(C)Ljava/lang/String;

    move-result-object v5

    move-object/from16 v0, p2

    move/from16 v1, v41

    move/from16 v2, v40

    move-object v3, v5

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 265
    sget-object v5, Landroid/text/method/QwertyKeyListener;->OLD_SEL_START:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanStart(Ljava/lang/Object;)I

    move-result v33

    .line 266
    .local v33, oldStart:I
    invoke-static/range {p2 .. p2}, Landroid/text/Selection;->getSelectionEnd(Ljava/lang/CharSequence;)I

    move-result v40

    .line 268
    move/from16 v0, v33

    move/from16 v1, v40

    if-ge v0, v1, :cond_2b0

    .line 269
    sget-object v5, Landroid/text/method/TextKeyListener;->LAST_TYPED:Ljava/lang/Object;

    const/16 v6, 0x21

    move-object/from16 v0, p2

    move-object v1, v5

    move/from16 v2, v33

    move/from16 v3, v40

    move v4, v6

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    .line 273
    if-eqz v25, :cond_2b0

    .line 274
    move-object/from16 v0, p2

    move/from16 v1, v33

    move/from16 v2, v40

    invoke-static {v0, v1, v2}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;II)V

    .line 275
    sget-object v5, Landroid/text/method/TextKeyListener;->ACTIVE:Ljava/lang/Object;

    const/16 v6, 0x21

    move-object/from16 v0, p2

    move-object v1, v5

    move/from16 v2, v33

    move/from16 v3, v40

    move v4, v6

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    .line 280
    :cond_2b0
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->adjustMetaAfterKeypress(Landroid/text/Spannable;)V

    .line 285
    and-int/lit8 v5, v35, 0x2

    if-eqz v5, :cond_3c3

    move-object/from16 v0, p0

    iget-boolean v0, v0, Landroid/text/method/QwertyKeyListener;->mAutoText:Z

    move v5, v0

    if-eqz v5, :cond_3c3

    const/16 v5, 0x20

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0x9

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0xa

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0x2c

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0x2e

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0x21

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0x3f

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    const/16 v5, 0x22

    move/from16 v0, v29

    move v1, v5

    if-eq v0, v1, :cond_2fe

    invoke-static/range {v29 .. v29}, Ljava/lang/Character;->getType(I)I

    move-result v5

    const/16 v6, 0x16

    if-ne v5, v6, :cond_3c3

    :cond_2fe
    sget-object v5, Landroid/text/method/TextKeyListener;->INHIBIT_REPLACEMENT:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanEnd(Ljava/lang/Object;)I

    move-result v5

    move v0, v5

    move/from16 v1, v33

    if-eq v0, v1, :cond_3c3

    .line 293
    move/from16 v45, v33

    .local v45, x:I
    :goto_30e
    if-lez v45, :cond_324

    .line 294
    const/4 v5, 0x1

    sub-int v5, v45, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v8

    .line 295
    .restart local v8       #c:C
    const/16 v5, 0x27

    if-eq v8, v5, :cond_38c

    invoke-static {v8}, Ljava/lang/Character;->isLetter(C)Z

    move-result v5

    if-nez v5, :cond_38c

    .line 300
    .end local v8           #c:C
    :cond_324
    move-object/from16 v0, p0

    move-object/from16 v1, p2

    move/from16 v2, v45

    move/from16 v3, v33

    move-object/from16 v4, p1

    invoke-direct {v0, v1, v2, v3, v4}, Landroid/text/method/QwertyKeyListener;->getReplacement(Ljava/lang/CharSequence;IILandroid/view/View;)Ljava/lang/String;

    move-result-object v36

    .line 302
    .local v36, rep:Ljava/lang/String;
    if-eqz v36, :cond_3c3

    .line 303
    const/4 v5, 0x0

    invoke-interface/range {p2 .. p2}, Landroid/text/Editable;->length()I

    move-result v6

    const-class v7, Landroid/text/method/QwertyKeyListener$Replaced;

    move-object/from16 v0, p2

    move v1, v5

    move v2, v6

    move-object v3, v7

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->getSpans(IILjava/lang/Class;)[Ljava/lang/Object;

    move-result-object v37

    check-cast v37, [Landroid/text/method/QwertyKeyListener$Replaced;

    .line 305
    .local v37, repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    const/16 v17, 0x0

    :goto_348
    move-object/from16 v0, v37

    array-length v0, v0

    move v5, v0

    move/from16 v0, v17

    move v1, v5

    if-ge v0, v1, :cond_38f

    .line 306
    aget-object v5, v37, v17

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    .line 305
    add-int/lit8 v17, v17, 0x1

    goto :goto_348

    .line 202
    .end local v25           #dead:Z
    .end local v33           #oldStart:I
    .end local v36           #rep:Ljava/lang/String;
    .end local v37           #repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    .end local v45           #x:I
    .restart local v22       #ch:I
    .restart local v43       #start:I
    :cond_35c
    const/16 v29, 0x0

    goto/16 :goto_1b3

    .line 243
    .end local v22           #ch:I
    .end local v43           #start:I
    .restart local v25       #dead:Z
    .restart local v27       #flags:I
    .restart local v44       #where:I
    :cond_360
    shl-int/lit8 v27, v29, 0x10

    .line 244
    invoke-static/range {v29 .. v29}, Ljava/lang/Character;->toUpperCase(I)I

    move-result v29

    .line 246
    if-nez v41, :cond_379

    .line 247
    sget-object v5, Landroid/text/method/TextKeyListener;->CAPPED:Ljava/lang/Object;

    const/4 v6, 0x0

    const/4 v7, 0x0

    or-int/lit8 v8, v27, 0x11

    move-object/from16 v0, p2

    move-object v1, v5

    move v2, v6

    move v3, v7

    move v4, v8

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto/16 :goto_246

    .line 250
    :cond_379
    sget-object v5, Landroid/text/method/TextKeyListener;->CAPPED:Ljava/lang/Object;

    const/4 v6, 0x1

    sub-int v6, v41, v6

    or-int/lit8 v7, v27, 0x21

    move-object/from16 v0, p2

    move-object v1, v5

    move v2, v6

    move/from16 v3, v41

    move v4, v7

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto/16 :goto_246

    .line 293
    .end local v27           #flags:I
    .end local v44           #where:I
    .restart local v8       #c:C
    .restart local v33       #oldStart:I
    .restart local v45       #x:I
    :cond_38c
    add-int/lit8 v45, v45, -0x1

    goto :goto_30e

    .line 308
    .end local v8           #c:C
    .restart local v36       #rep:Ljava/lang/String;
    .restart local v37       #repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    :cond_38f
    sub-int v5, v33, v45

    move v0, v5

    new-array v0, v0, [C

    move-object/from16 v34, v0

    .line 309
    .local v34, orig:[C
    const/4 v5, 0x0

    move-object/from16 v0, p2

    move/from16 v1, v45

    move/from16 v2, v33

    move-object/from16 v3, v34

    move v4, v5

    invoke-static {v0, v1, v2, v3, v4}, Landroid/text/TextUtils;->getChars(Ljava/lang/CharSequence;II[CI)V

    .line 311
    new-instance v5, Landroid/text/method/QwertyKeyListener$Replaced;

    move-object v0, v5

    move-object/from16 v1, v34

    invoke-direct {v0, v1}, Landroid/text/method/QwertyKeyListener$Replaced;-><init>([C)V

    const/16 v6, 0x21

    move-object/from16 v0, p2

    move-object v1, v5

    move/from16 v2, v45

    move/from16 v3, v33

    move v4, v6

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    .line 313
    move-object/from16 v0, p2

    move/from16 v1, v45

    move/from16 v2, v33

    move-object/from16 v3, v36

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 319
    .end local v34           #orig:[C
    .end local v36           #rep:Ljava/lang/String;
    .end local v37           #repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    .end local v45           #x:I
    :cond_3c3
    and-int/lit8 v5, v35, 0x4

    if-eqz v5, :cond_437

    move-object/from16 v0, p0

    iget-boolean v0, v0, Landroid/text/method/QwertyKeyListener;->mAutoText:Z

    move v5, v0

    if-eqz v5, :cond_437

    .line 320
    invoke-static/range {p2 .. p2}, Landroid/text/Selection;->getSelectionEnd(Ljava/lang/CharSequence;)I

    move-result v40

    .line 321
    const/4 v5, 0x3

    sub-int v5, v40, v5

    if-ltz v5, :cond_437

    .line 322
    const/4 v5, 0x1

    sub-int v5, v40, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v5

    const/16 v6, 0x20

    if-ne v5, v6, :cond_437

    const/4 v5, 0x2

    sub-int v5, v40, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v5

    const/16 v6, 0x20

    if-ne v5, v6, :cond_437

    .line 324
    const/4 v5, 0x3

    sub-int v5, v40, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v8

    .line 326
    .restart local v8       #c:C
    const/4 v5, 0x3

    sub-int v30, v40, v5

    .local v30, j:I
    :goto_400
    if-lez v30, :cond_41b

    .line 327
    const/16 v5, 0x22

    if-eq v8, v5, :cond_40e

    invoke-static {v8}, Ljava/lang/Character;->getType(C)I

    move-result v5

    const/16 v6, 0x16

    if-ne v5, v6, :cond_41b

    .line 329
    :cond_40e
    const/4 v5, 0x1

    sub-int v5, v30, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v8

    .line 326
    add-int/lit8 v30, v30, -0x1

    goto :goto_400

    .line 335
    :cond_41b
    invoke-static {v8}, Ljava/lang/Character;->isLetter(C)Z

    move-result v5

    if-nez v5, :cond_427

    invoke-static {v8}, Ljava/lang/Character;->isDigit(C)Z

    move-result v5

    if-eqz v5, :cond_437

    .line 336
    :cond_427
    const/4 v5, 0x2

    sub-int v5, v40, v5

    const/4 v6, 0x1

    sub-int v6, v40, v6

    const-string v7, "."

    move-object/from16 v0, p2

    move v1, v5

    move v2, v6

    move-object v3, v7

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 342
    .end local v8           #c:C
    .end local v30           #j:I
    :cond_437
    const/4 v5, 0x1

    goto/16 :goto_117

    .line 343
    .end local v25           #dead:Z
    .end local v33           #oldStart:I
    :cond_43a
    const/16 v5, 0x54

    move/from16 v0, p3

    move v1, v5

    if-eq v0, v1, :cond_449

    invoke-virtual/range {p4 .. p4}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v5

    const/16 v6, 0x5c

    if-ne v5, v6, :cond_45f

    :cond_449
    invoke-virtual/range {p4 .. p4}, Landroid/view/KeyEvent;->getScanCode()I

    move-result v5

    const/16 v6, 0xd9

    if-ne v5, v6, :cond_45f

    invoke-virtual/range {p4 .. p4}, Landroid/view/KeyEvent;->getFlags()I

    move-result v5

    and-int/lit8 v5, v5, 0x40

    if-nez v5, :cond_45f

    .line 344
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->resetMetaState(Landroid/text/Spannable;)V

    .line 345
    const/4 v5, 0x1

    goto/16 :goto_117

    .line 346
    :cond_45f
    const/16 v5, 0x43

    move/from16 v0, p3

    move v1, v5

    if-ne v0, v1, :cond_525

    move/from16 v0, v41

    move/from16 v1, v40

    if-ne v0, v1, :cond_525

    .line 349
    const/16 v24, 0x1

    .line 356
    .local v24, consider:I
    sget-object v5, Landroid/text/method/TextKeyListener;->LAST_TYPED:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanEnd(Ljava/lang/Object;)I

    move-result v5

    move v0, v5

    move/from16 v1, v41

    if-ne v0, v1, :cond_48c

    .line 357
    const/4 v5, 0x1

    sub-int v5, v41, v5

    move-object/from16 v0, p2

    move v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->charAt(I)C

    move-result v5

    const/16 v6, 0xa

    if-eq v5, v6, :cond_48c

    .line 358
    const/16 v24, 0x2

    .line 361
    :cond_48c
    sub-int v5, v41, v24

    const-class v6, Landroid/text/method/QwertyKeyListener$Replaced;

    move-object/from16 v0, p2

    move v1, v5

    move/from16 v2, v41

    move-object v3, v6

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->getSpans(IILjava/lang/Class;)[Ljava/lang/Object;

    move-result-object v37

    check-cast v37, [Landroid/text/method/QwertyKeyListener$Replaced;

    .line 364
    .restart local v37       #repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    move-object/from16 v0, v37

    array-length v0, v0

    move v5, v0

    if-lez v5, :cond_525

    .line 365
    const/4 v5, 0x0

    aget-object v5, v37, v5

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanStart(Ljava/lang/Object;)I

    move-result v42

    .line 366
    .local v42, st:I
    const/4 v5, 0x0

    aget-object v5, v37, v5

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanEnd(Ljava/lang/Object;)I

    move-result v26

    .line 367
    .local v26, en:I
    new-instance v31, Ljava/lang/String;

    const/4 v5, 0x0

    aget-object v5, v37, v5

    invoke-static {v5}, Landroid/text/method/QwertyKeyListener$Replaced;->access$000(Landroid/text/method/QwertyKeyListener$Replaced;)[C

    move-result-object v5

    move-object/from16 v0, v31

    move-object v1, v5

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([C)V

    .line 369
    .local v31, old:Ljava/lang/String;
    const/4 v5, 0x0

    aget-object v5, v37, v5

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    .line 375
    move/from16 v0, v41

    move/from16 v1, v26

    if-lt v0, v1, :cond_51c

    .line 376
    sget-object v5, Landroid/text/method/TextKeyListener;->INHIBIT_REPLACEMENT:Ljava/lang/Object;

    const/16 v6, 0x22

    move-object/from16 v0, p2

    move-object v1, v5

    move/from16 v2, v26

    move/from16 v3, v26

    move v4, v6

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    .line 378
    move-object/from16 v0, p2

    move/from16 v1, v42

    move/from16 v2, v26

    move-object/from16 v3, v31

    invoke-interface {v0, v1, v2, v3}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 380
    sget-object v5, Landroid/text/method/TextKeyListener;->INHIBIT_REPLACEMENT:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->getSpanStart(Ljava/lang/Object;)I

    move-result v26

    .line 381
    const/4 v5, 0x1

    sub-int v5, v26, v5

    if-ltz v5, :cond_513

    .line 382
    sget-object v5, Landroid/text/method/TextKeyListener;->INHIBIT_REPLACEMENT:Ljava/lang/Object;

    const/4 v6, 0x1

    sub-int v6, v26, v6

    const/16 v7, 0x21

    move-object/from16 v0, p2

    move-object v1, v5

    move v2, v6

    move/from16 v3, v26

    move v4, v7

    invoke-interface {v0, v1, v2, v3, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    .line 388
    :goto_50d
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->adjustMetaAfterKeypress(Landroid/text/Spannable;)V

    .line 394
    const/4 v5, 0x1

    goto/16 :goto_117

    .line 386
    :cond_513
    sget-object v5, Landroid/text/method/TextKeyListener;->INHIBIT_REPLACEMENT:Ljava/lang/Object;

    move-object/from16 v0, p2

    move-object v1, v5

    invoke-interface {v0, v1}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    goto :goto_50d

    .line 390
    :cond_51c
    invoke-static/range {p2 .. p2}, Landroid/text/method/QwertyKeyListener;->adjustMetaAfterKeypress(Landroid/text/Spannable;)V

    .line 391
    invoke-super/range {p0 .. p4}, Landroid/text/method/BaseKeyListener;->onKeyDown(Landroid/view/View;Landroid/text/Editable;ILandroid/view/KeyEvent;)Z

    move-result v5

    goto/16 :goto_117

    .line 398
    .end local v24           #consider:I
    .end local v26           #en:I
    .end local v31           #old:Ljava/lang/String;
    .end local v37           #repl:[Landroid/text/method/QwertyKeyListener$Replaced;
    .end local v42           #st:I
    :cond_525
    invoke-super/range {p0 .. p4}, Landroid/text/method/BaseKeyListener;->onKeyDown(Landroid/view/View;Landroid/text/Editable;ILandroid/view/KeyEvent;)Z

    move-result v5

    goto/16 :goto_117

    .line 195
    .restart local v22       #ch:I
    .restart local v43       #start:I
    :catch_52b
    move-exception v5

    goto/16 :goto_1a4
.end method

.method public onKeyUp(Landroid/view/View;Landroid/text/Editable;ILandroid/view/KeyEvent;)Z
    .registers 7
    .parameter "view"
    .parameter "content"
    .parameter "keyCode"
    .parameter "event"

    .prologue
    .line 82
    const/16 v0, 0x54

    if-eq p3, v0, :cond_c

    invoke-virtual {p4}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v0

    const/16 v1, 0x5c

    if-ne v0, v1, :cond_24

    :cond_c
    invoke-virtual {p4}, Landroid/view/KeyEvent;->getScanCode()I

    move-result v0

    const/16 v1, 0xd9

    if-ne v0, v1, :cond_24

    invoke-virtual {p4}, Landroid/view/KeyEvent;->getFlags()I

    move-result v0

    and-int/lit8 v0, v0, 0x40

    if-nez v0, :cond_24

    .line 83
    invoke-virtual {p4, p1}, Landroid/view/KeyEvent;->switchLayout(Landroid/view/View;)V

    .line 84
    invoke-static {p2}, Landroid/text/method/QwertyKeyListener;->resetMetaState(Landroid/text/Spannable;)V

    .line 85
    const/4 v0, 0x1

    .line 88
    :goto_23
    return v0

    :cond_24
    invoke-super {p0, p1, p2, p3, p4}, Landroid/text/method/BaseKeyListener;->onKeyUp(Landroid/view/View;Landroid/text/Editable;ILandroid/view/KeyEvent;)Z

    move-result v0

    goto :goto_23
.end method
