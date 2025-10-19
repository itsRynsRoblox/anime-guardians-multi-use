#Requires AutoHotkey v2.0

; === Image Paths ===
global Minimize := "Images\minimizeButton.png" 
global Exitbutton := "Images\exitButton.png"
global Disconnected := "Images\disconnected.png"
global Import := "Images\import.png"
global Export := "Images\export.png"

;=== General FindText Text and Buttons ===
Disconnect:="|<>*154$122.zznzzzzzzzzzzzzzzzzws7szzzzzzzzzzzzzDzzzC0TDzzzzzzzzzzzznzzznb3zzzzzzzzzzzzzwzzzwtwzzzzzzzzzzzzzzDzzzCT7DVy7kz8T8TkzV0S7sHblnUC0k7k3k3k7U060w0tyQsrXMswMwMstsrD7CCCTbCDlyDDDDDCTATnntXnblnkwzblnnnnU3Dww0NwtwQz3DtwQwwws0nzD06TCTDDwlyDDDDDCTwTnnzXnb3nbADXXnnnnXr3wQSsss1ws3UA1wwwww1s31UD0C1zD1y7kzDDDDkzVsS7sHU"
OpenChat:="|<>*154$30.zzzzzzzzzzw000Ds0007s0007s0007s0007s0007s7zs7s7zs7s0007s0007s0z07s1zU7s0007s0007s0007s0007s0007zs07zzy0Tzzz0zzzzVzzzznzzzzzzzU"

; === Anime Guardians ===
LobbySettings:="|<>*149$23.zzzzzszzzlzzr1rz007w007w00DsDUzkzVz3zVs7z0kDy1UTw3kzsTkzVzUy3z007w007w00TxkRzzlzzzXzzzzzk"
IngameSettings:="|<>*67$23.zzzzzszzzlzzr1rz007w007w00DsDUzkzVz3zVs7z0kDy1UTw3kzsTkzVzUy3z007w007w00TxkRzzlzzzXzzzzzk"
SuperFastWave:="|<>*23$43.zs0000TsC00007c300001w1xzy7vyBzzzrDx7tlUS1UUQsk60EM6QMV68zVCAs04wsX6AE6O8E30MzB0Q1UA1akTAmTUnTxztwzzDsDwk7W7U06M003s03w001y00w000U"
Results:="|<>*117$32.zzzzzs1zjyC0DnzXwSwTsz6220DlU0U3wFYl0z4F4EDlUkU1wwCA4Tzzzzy"
SummerEvent:="|<>*164$74.0000000000000zzk000000000zzy0000000z0C01k000000Ts300A000000CC0k0300000031UQ00w7lzVzskS700TXyzzzzw7lkzyQly3wty0CQDz3QC0C0703b01Uy303U0k0tk0Q7VU0M060CQ071kMC601U3b01sAC7VUsQ7lkTy23U0MS31sQDzk1s0C7UkS73zy0S7zVsC7lk07UDUMsS3UQQ00w7Q0C7Us3700D1r03VsC0kk07ssw0sT7sQDzzry7zzzzzz1zztz0zzzDtzW"
MaxUpgradeText:="|<>*93$31.S7k00Tbs008z6004D3zzm31zrh0Uk1XU0E01l21W1cn0lVoTU0UODl007aMk9bzDzzzD3nzb8"
UnitManager:="|<>*148$42.wSTzzzzk6TzzzzU6Tzzzz3aTjzzz7yS1kC1DyQ1kA1DyQMlwMDyQskA07yQssA1U6A0rATU661kA1sD73kS1U"
UnitManagerGameOver:="|<>*56$47.zzzzzzzzzzzzzzzzzzzzzzzzwSTzzzzzUAzzzzzy0NzzzzzsQnxzzwzlzbUQ3UTbzC0M60yDyQMlwMyTwllUE1wTtnXUk7s0lU6NXzs1V0Q30Tw7XVsD0zzzzzzzzzzzzzzzzzzzzzzzzU"
CSMEvent:="|<>*162$73.zzzzzzzzzzzzzzzzzzzzzzzzz01zzzzzzzzzz00DzzzzzzyDzU07zzzzzzz3zk03zzzzzzzVzs03zzzzzzzkzwDzbyzUzCTU7y7zVy70D03k1z03Uy303U0k0zU0sD300k0A0Tk0Q71UsM070Ts0D1VkwAD3kzwDzkUs067UsTy7zs0w073kQDz3zy0S7zVsC7zU0D0T0lkw70zk03kTk0sS3UDs01wDw0QD3s7y01yDz0D7ly7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"


JoinMatchmaking:="|<>*130$75.zzzzzzzzzzzzzzzzzzzy3zzzzzzzzzzzkDzzzzzw7zzzw1zzzzzz0zzzzUDzzzzzs7zzzy1zzzzzz0zzzzkTzzzzzs7zzzzzzzzzzz0zzzzzzzzzzzs7zzzzzzzzzzz0zs1zkS3Uzzzs7w03y1k01zzz0z00DUA007zzs7k00w1U00Tzz0w007UA003zzs7U00Q1U00Dzz0s1s3UA0M1zzs70TUA1UDUDzz0s7w1UA1y1zzs70zUA1UDkDzz0s7w1UA1y1y7k70TUA1UDkDUQ0s1k3UA1y1w007U00Q1UDkDU01w007UA1y1w00Tk00w1UDkDk03z00DUA1y1z01zw03y1kDkDy0Tzs1zkS3z1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
Raids:="|<>*96$50.000000000D00s0000Dy0T000s7bUAM00T30Tv7wTgNk7znzzz7MzkwsT1Uq7k68300AkQsWQFbDC00800zXbw02E0Dsnj0zYTXiCk30FUA1Vi1sAQ7UwNzzzzzzzy7sTCDVwT000000002"
InfinityCastleUI:="|<>*151$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU1zzzzzzzzw00zzyDzzzzs01zzwDzzzzk03zzsTzzzzU0Dzzkzzzzz3zwty0TUzCS7zk0s0Q0w0Q0DU0k0k0s0M0D00k100k1k0S01k63VUrU0wD3kwD33z3zsS3Vs067y7zkw73k0QCADzVsC7VzsQM033kw31lksk027Vs303VlU0ADXs7073XU0QT7sT0D67zzzrxzzzzw7zzz7kzbzjk00000001s00U"

; === Upgrade Limits === 279, 311, 377, 334
Upgrade0:="|<>*96$18.zzzVlVX0Vb4NbANaCNbCNbANb0tbVtbzlVzVzzzzzzU"
Upgrade1:="|<>*98$15.zzw0VW4AstbbAwtbbAwtbbAwtbyADVzzzzzU"
Upgrade2:="|<>*97$17.zzz36684Av6NyAnwtbnnCDaQ3Ak6NzskzVzzzzzy"
Upgrade3:="|<>*96$17.zzz22680AyCNwwnktbsnDtaM3AsCNzskzVzzzzzy"
Upgrade4:="|<>*96$19.zzzkwsMwQAyTaSDnC9tb0Qn06Nz7AzbaTzX3zVzzzk"
Upgrade5:="|<>*98$17.zzz226A0AtyNlwnUtbsnDtaQ3AsCNzskzVzzzzzy"
Upgrade6:="|<>*96$18.zzzVkVXUVb7tbDta0ta4NbANb0tbVtbzlVzVzzzU"
Upgrade7:="|<>*95$18.zzzV0VW0Va8tbMtbttbltbntbXtbXtbzlVzVzzzzzzU"
Upgrade8:="|<>*95$18.zzzVVVX0VbANb4tb0tb4NaANb0NbUtbzlVzVzzzzzzU"
Upgrade9:="|<>*90$22.zzzy3bkM871XUD6AQQMlllXU76D0QMzllXyD6C0wMsDlXzz67zkMTz1zzzy"

Upgrade10:="|<>*43$11.zzzztq1c2MEk3Y7zzzs"
Upgrade11:="|<>*41$11.zzzr1Y2QYt3m7zzzw"
Upgrade12:="|<>*45$13.zzzzznj0n0Hn9s1w0zzzzy"
Upgrade13:="|<>*45$11.zzzztq1cWNYk3U7zzzs"
Upgrade14:="|<>*44$13.zzzyw341/0bU7nXzzzzw"

; === Nuke Wave Configuration ===
Wave15:="|<>*127$34.zzzzzzb1wtkQ87X21UUS8842Dk0Xs8D623s0MS07W1XsUSDWDXss0Fy07U17s0SM8za3zzrzzy"

Wave20 := "|<>*84$16.zzzzzz6DsETY9zYbwGzUXzzzzzy"
Wave50 := "|<>*110$10.zz4M1WG1C5n7zs"

; === Gates ===
GateUI:="|<>*167$107.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyDzzzzzzzzzzzzzzzzkDzzzzzzzzzzzzzzzzUDzzzzzzzzzzzzzzzz0Tzzzzzzzzk7zzzz1y0zzzzzzzzz0Dzzzw3y3zzzzzzzzy0Dzzzs7zzzzzzzzzzs0TzzzkDzzzzzzzzzzk0Ty0DUDk87s7k3zzzU0zs0A07UE7kD01zzy11zU080D0kD0w01zzw61y0000S1US1k01zzkA3s3UU0w3UQ70w3zzUQ3kDbkDs70kC1w7zy1s7UTzUTkC1UQ00Dzw0070zz0zUS01s00Tzk00C1zy1z0w03k00zzU00Q1tw3y1w0DUTzzz000M00s3w3s0T0STzw1y0s00s1s7k1z00Tzs7y0s03k1kDk3z00TzUDy1s0Dk3UTU7z00zz0zw1w1zk70zUTzU7zzzzzzzzzzzzzzzzzzy"
ARank:="|<>*123$36.zzzzzzzzVzzjwz0zzDsT4zzDsTAU11kD0001kD0AA3X7A0A1bbiUA9zzzzzzU"
BRank:="|<>*124$34.zzzzzz3szzvs70zzDWQHzwyFn80EN70001aQ0kkC1n030QDiUA9zzzzzy"
CRank:="|<>*122$35.zzzzzzsy7zyz0s7ztyPlDzntzaE0Unz0001Xy0MM7UQk0k7Vxo1VDzzzzzs"
DRank:="|<>*123$35.zzzzzzVy7zyy1s7ztwFlDzntnaE0Unb0001bC0MM70wk0k73xo1VDzzzzzs"
SRank:="|<>*122$34.zzzzzzXsTzvwD0zzDXwHzwz7n80EQ70001yQ0kkC1n030QDiUA9zzzzzy"
NationalRank:="|<>*125$43.zzzzzzzvzzrzzysnyPzzyQ9z7vzzC4U0kUk700EE003a399VVVn0460k0Rm333N1Dzzzzzzy"

; === Card Selection ===
CardSelection:="|<>*139$39.00000000Q0k00DykD0011o1M0097zvszWQa6Ng2HYamNAW0VC4GYER/kmIWwgaG94Y9lb90XUvvi7s0000004"

; === Portal ===
MarineFordPortal:="|<>*114$85.zzzzzzzzzzzzzzzxzzzzzzzzzzxzw2zzsDzzzkDzyzza3zsbzzns7wmTzn1Vsw8Mlw2AFADtW0wQ0B8y1G8Y7wn0DAA26T01aG1yRVzU6SHDU4nBDzCm7w/VVXkMMWkzzzzzzzzzzzzzzy"
PortalUseButton:="|<>*153$38.0000007kz0003aAk000lW4000ATVzzzz7sTzzzly7bz7wTVUD0T7sE3U7ly4TkkwTV1wSD3sE703kyD0k1y73yATzU1k307w0w0s1zkTUT0Tzzzzzzzzzzzzs"
DemonDistrictPortal:="|<>*109$76.zzzzzzzzzzzzzzzzzzzztzzbzw3zzzzz0jzyzzk7zzzzw0zbvzDA1U667n34MA8ws6000DC9l0UXn09AAAwklYmTD0DYk2nk3mPcAw66n8PD1cMiklzzzzzzzzzzzzy"
GuestUICheck:="|<>*145$96.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw0TzzzzzzzzzzzzzU03zzzzzzzzzzzzz001y3zzzzzzzz1zy003y3zzzzzzzz1zw0Q3w3zzzzzzzy1zw3zbw3zzzzzzzy1zs7zzs3zw1kD1kw1zs7zzU0Dk0ET10k07s7zzU0DU00T00k07s3zzU0D000T01k07w0TzU0S0Q0T01k0Dw03zsDw1y0S0Tw7zC00xsDw3z0y1zw7wDU0CsCQ730y1sQ707s0CkAM730y3UM601zU6kAM630y3UM60ATs7kQM630w30sC0z3s7kQM671w30sC0zzs7kSM7y1w70sD0Xzs7kTs3w1w70sDsUTUDkDw1s1w70s7s000Rk0w001s60s0M000Rk0y003s60s0MU01ss0r003sC0Q0Mw07kw1nk63sC0S0szzzUTzlzzzTw0DzsDzy07zUzzyDs03zk0zU00s07U00000Q0U"
;Outdated FindText
Retry := "|<>*115$29.000000000000000w20024+0047nzk9802EE09l0U2GW194ZY1zzmE0004U000600000000004"
StartButton := "|<>*121$25.00003s043y0735U6l2zzQW402wgdrtG4ty9WQzzzzzzzzz"