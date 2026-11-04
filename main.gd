extends Node2D
# ARENA BOLA - Battle Royale 2D
# Port dari versi HTML ke Godot 4.3+ (GDScript). Semua digambar lewat _draw().
# Perbaikan: tombol MENU, MUTE dan 2.5D ada di baris atas (kiri minimap),
# jadi tidak lagi tertutup tombol aksi di kanan bawah.

const W := 20000.0
const GN := 400
const PLEN := 24000.0
const ZD := 80.0
const ZS := 70.0
const SRATE := 16000
const ZR := [7600.0, 4800.0, 3000.0, 1700.0, 800.0, 40.0]
const NM := ["Rio", "Dewi", "Bagas", "Sari", "Joko", "Mega", "Ucok", "Nina", "Fajar", "Tika", "Andi", "Lala", "Budi", "Maya", "Reza", "Putri"]
const RN := ["Biasa", "Common", "Rare", "Epic", "Legend"]
const RW := [48.0, 28.0, 15.0, 7.0, 2.0]
const TN := ["Kipas", "Cincin", "Spiral", "Bintang", "Gelombang", "Hujan", "Heliks", "Pusaran"]
const SKN := [["Dash", 14], ["Perisai Aura", 25], ["Penyembuh", 30], ["Kilat", 18], ["Nova", 22], ["Teleport", 20], ["Amarah", 25], ["Pengisap Nyawa", 25], ["Asap", 24], ["Pembeku", 22]]
const BTN := ["ba", "bi", "bs", "bm", "bx", "ib", "bz", "mu"]

# ---------------------------------------------------------------- kelas data
class Wpn:
	var name := ""
	var cat := 0
	var d := 0.0
	var r := 0.0
	var s := 0.0
	var g := 0.0
	var p := 1
	var sp := 0.0
	var col := Color.WHITE
	var a := 0.0
	var f := ""
	var ci := 0
	var rr := 0

class Box:
	var x := 0.0
	var y := 0.0
	var w := 0.0
	var h := 0.0
	var f := 2
	var c := Color.GRAY
	var m := false
	var sx := 0.0
	var sy := 0.0
	var sw := 0.0
	var sh := 0.0

class Item:
	var x := 0.0
	var y := 0.0
	var k := "w"
	var w := -1
	var nb := false
	var fl := 0

class Ent:
	var id := 0
	var human := false
	var nm := ""
	var col := Color.WHITE
	var x := 0.0
	var y := 0.0
	var hp := 100.0
	var ar := 0.0
	var w := -1
	var cd := 0.0
	var ang := 0.0
	var alive := true
	var st := 0
	var fl := 0
	var stc := 0.0
	var im := false
	var jt := 0.0
	var kills := 0
	var slow := 0.0
	var pois := 0.0
	var rt := 0.0
	var sd := 1
	var fT := 0.0
	var pk := 0.0
	var avT := 0.0
	var av := 0.0
	var lx := 0.0
	var ly := 0.0
	var sk := 0.0
	var mk := 1
	var ks := 0
	var sc := 0.0
	var inv := 0.0
	var spd := 0.0
	var rage := 0.0
	var ls := 0.0
	var cl := 0.0
	var hl := 0.0
	var sh := 0.0
	var bf := 0.0
	var seen := 0.0
	var vis := false
	var lkx := 0.0
	var lky := 0.0
	var tx := 0.0
	var ty := 0.0
	var tg = null
	var has_wp := false
	var wpx := 0.0
	var wpy := 0.0
	var it = null

class Bul:
	var fl := 0
	var x := 0.0
	var y := 0.0
	var vx := 0.0
	var vy := 0.0
	var l := 0.0
	var l0 := 0.0
	var w := 0
	var o = null
	var pierce := false
	var hit := {}
	var rv := false

# ---------------------------------------------------------------- state
var vw := 800.0
var vh := 360.0
var font: Font
var CC := {}
var RC: Array = []
var TXC: Array = []
var TC: Array = []
var BCOL := {}
var playing := false
var iso := false
var paused := false
var over := false
var mapOn := false
var mut := false
var tab := 0
var ski := false
var med := false
var inter := false
var att := false
var att_t := -1
var joy := {"on": false, "id": -1, "bx": 0.0, "by": 0.0, "mx": 0.0, "my": 0.0}
var touches := {}
var S := {"co": 0, "own": {}, "w": -1, "a": 0, "m": 0, "sk": -1}
var WP: Array = []
var WB: Array = [[], [], [], [], []]
var SKM: Array = []
var GEAR: Array = []

var rng := RandomNumberGenerator.new()
var GR := PackedByteArray()
var BRI := PackedByteArray()
var walls: Array = []
var bk := {}
var B: Array = []
var BBK := {}
var DR: Array = []
var deco := {}
var loot: Array = []
var MN: Array = []
var IC: Array = []
var BE: Array = []
var FA: Array = []
var MM: ImageTexture

var ents: Array = []
var items: Array = []
var bul: Array = []
var fx: Array = []
var feed: Array = []
var em: Array = []
var skcd := 0.0
var Z := {}
var PA := {}
var pt := 0.0
var pdur := 0.0
var tEnd := 0.0
var seedV := ""
var specT = null

var V0x := 0.0
var V0y := 0.0
var V1x := 0.0
var V1y := 0.0
var cur := Transform2D.IDENTITY
var ga := 1.0

# audio
var AC_ok := false
var sfxp: Array = []
var sfxi := 0
var sfxs := {}
var mus := {}
var musp: AudioStreamPlayer
var cur_mi := -1
var _buf := PackedFloat32Array()

# ui
var ui: CanvasLayer
var pans := {}
var lbl_cc: Label
var lbl_mc: Label
var lbl_et: Label
var lbl_es: Label
var seed_edit: LineEdit
var grid: GridContainer

# ---------------------------------------------------------------- util
func hc(s: String) -> Color:
	if not CC.has(s):
		CC[s] = Color(s)
	return CC[s]

func hsl(h: float, s: float, l: float, a: float = 1.0) -> Color:
	h = fposmod(h, 360.0) / 360.0
	var v := l + s * minf(l, 1.0 - l)
	var sv := 0.0
	if v > 0.0:
		sv = 2.0 * (1.0 - l / v)
	return Color.from_hsv(h, sv, v, a)

func hyp(a: float, b: float) -> float:
	return sqrt(a * a + b * b)

func sr() -> float:
	return rng.randf()

func ad(a: float, b: float) -> float:
	return absf(fposmod(a - b + 9.4248, 6.2832) - 3.1416)

func ca(c: Color) -> Color:
	return Color(c.r, c.g, c.b, c.a * ga)

func iv(x: float, y: float) -> Vector2:
	if iso:
		return Vector2((x + 2.0 * y) * .7071, (2.0 * y - x) * .7071)
	return Vector2(x, y)

func fmt(s: float) -> String:
	var m := int(s / 60.0)
	var sec := int(ceil(fmod(s, 60.0))) % 60
	return "%d:%02d" % [m, sec]

func _ready():
	randomize()
	font = ThemeDB.fallback_font
	RC = [hc("#9aa7b5"), hc("#3b82f6"), hc("#facc15"), hc("#a855f7"), hc("#ef4444")]
	TXC = [
		[hc("#2a6f9e"), hc("#2c75a6"), hc("#276a98")],
		[hc("#e6d9a3"), hc("#decf96"), hc("#ece0ae")],
		[hc("#5b9b49"), hc("#559345"), hc("#609f4d")],
		[hc("#3d7a3d"), hc("#387237"), hc("#438240")],
		[hc("#dac68a"), hc("#d2bd7f"), hc("#e0cd95")],
		[hc("#e1ebf1"), hc("#d4e1ea"), hc("#eaf2f7")]]
	TC = [[hc("#2f7a34"), hc("#3d9142")], [hc("#245c2a"), hc("#2d6b32")], [hc("#1d5a40"), hc("#e9f4f9")]]
	BCOL = {"ba": hc("#e5484dcc"), "bi": hc("#3b82f6cc"), "bs": hc("#a855f7cc"), "bm": hc("#22c55ecc"), "bx": hc("#f97316cc"), "ib": hc("#000000aa"), "bz": hc("#000000aa"), "mu": hc("#000000aa")}
	init_weapons()
	ld()
	build_ui()
	pan("con")

# ---------------------------------------------------------------- data senjata
func init_weapons():
	var NMS := [
		["Tongkat Api", "Tongkat Es", "Tongkat Petir", "Tongkat Angin", "Tongkat Bayangan", "Tongkat Bintang", "Tongkat Lava", "Tongkat Kristal", "Tongkat Racun", "Tongkat Naga"],
		["Bola Arkana", "Ledakan Gaib", "Sihir Racun", "Panah Cahaya", "Badai Es", "Meteor Mini", "Rantai Petir", "Gelombang Roh", "Api Hitam", "Kutukan"],
		["Ketapel", "Bumerang", "Yo-yo", "Kipas Baja", "Lempar Pisau", "Bola Bowling", "Shuriken", "Jaring", "Panci Terbang", "Gergaji"],
		["Pistol", "SMG", "Shotgun", "Sniper", "Senapan Serbu", "Revolver", "LMG", "DMR", "Peluncur Granat", "Pistol Ganda"],
		["Pedang", "Tombak", "Busur", "Kapak", "Belati", "Gada", "Katana", "Trisula", "Cambuk", "Panah Api"],
		["Laser Mini", "Pulsar", "Railgun", "Plasma", "Drone Tempur", "Gravitasi", "Tesla", "Fusi", "Nano", "Antimateri"],
		["Palu Guntur", "Busur Bulan", "Tombak Surya", "Sabit Maut", "Cakar Naga", "Lonceng Neraka", "Cermin Dewa", "Tanduk Iblis", "Seruling Roh", "Mahkota Api"]]
	WP = []
	for c in range(NMS.size()):
		for i in range(10):
			var h := float((i * 7 + c * 3) % 10) / 10.0
			var d := 12.0 + h * 26.0
			var r := .2 + h * .8
			var s := 420.0 + h * 700.0
			var g := 300.0 + h * 400.0
			var p := 1
			var sp := .04
			var a := 0.0
			var f := ""
			if c == 4 and not (i in [2, 8, 9]):
				s = 0.0
				g = 70.0 + h * 70.0
				d = 24.0 + h * 24.0
				r = .3 + h * .4
				sp = .5 + (i % 3) * .15
			elif c == 3:
				s = 1000.0 + h * 1400.0
				g = 350.0 + h * 800.0
				d = 8.0 + h * 50.0
				r = .1 + h * 1.3
				sp = .02 + (1.0 - h) * .12
				if i == 2:
					p = 6
					sp = .38
					d = 9.0
					g = 300.0
					r = 1.0
				if i == 8:
					a = 80.0
					s = 500.0
					d = 40.0
					r = 1.4
			else:
				if i % 3 == 0:
					a = 40.0 + h * 50.0
				if i % 3 == 1:
					f = "s"
				if i % 4 == 2:
					f += "v"
				if c == 1 and i % 4 == 3:
					f += "p"
				if c == 2 and i % 2 == 1:
					f += "pb"
					g = minf(g, 300.0)
			var w := Wpn.new()
			w.name = NMS[c][i]
			w.cat = c
			w.d = floorf(d)
			w.r = snappedf(r, .01)
			w.s = floorf(s)
			w.g = floorf(g)
			w.p = p
			w.sp = sp
			w.col = hsl(float((c * 73 + i * 29) % 360), .9, .62)
			w.a = floorf(a)
			w.f = f
			w.ci = i
			WP.append(w)
	# kelangkaan (rarity) berdasarkan skor
	var sc := []
	for i2 in range(WP.size()):
		var w2: Wpn = WP[i2]
		var fac := 1.2
		if w2.s > 0.0:
			fac = 1.0 + w2.g / 900.0
		sc.append([w2.d * w2.p / w2.r * fac, i2])
	sc.sort_custom(func(a, b): return a[0] < b[0])
	var n := WP.size()
	var cut := [.3, .58, .8, .93, 1.0]
	WB = [[], [], [], [], []]
	for k in range(sc.size()):
		var rr := 0
		while float(k) / n >= cut[rr]:
			rr += 1
		var wi2: Wpn = WP[sc[k][1]]
		wi2.rr = rr
		wi2.col = RC[rr]
		WB[rr].append(sc[k][1])
	# senjata awal & item toko
	GEAR = [
		{"n": "Perisai Penuh", "p": 150, "k": "a", "d": "Mulai dengan armor 100"},
		{"n": "Medkit +2", "p": 120, "k": "m", "d": "Mulai dengan 3 medkit"}]
	var gn := ["Pistol", "Shotgun", "Senapan Serbu", "Sniper", "Railgun", "Palu Guntur"]
	var gp := [100, 220, 300, 450, 700, 1000]
	for q in range(6):
		var idx := wi(gn[q])
		var wg: Wpn = WP[idx]
		GEAR.append({"n": gn[q], "p": gp[q], "k": idx, "d": RN[wg.rr] + " · senjata awal"})
	# 30 skill marketplace
	SKM = []
	for z in range(30):
		var t := z % 8
		var L := z >> 3
		var cnt := (12 if t == 1 else 8) + L * (6 if t == 1 else 5) + (8 if t > 1 else 0)
		var dm := 11 + L * 5 + (t % 3) * 2
		var v := 480 + (t % 4) * 70
		var cd := 7 + L * 2
		var fl: String = ["", "s", "v", "p", "pb"][z % 5]
		var colr := hsl(z * 12.0, .9, .62)
		var nm: String = TN[t] + " " + ["I", "II", "III", "IV"][L]
		var sw := Wpn.new()
		sw.name = nm
		sw.cat = 0
		sw.d = float(dm)
		sw.r = 0.0
		sw.s = float(v)
		sw.g = 640.0
		sw.p = 1
		sw.sp = 0.0
		sw.col = colr
		sw.a = 0.0
		sw.f = fl
		WP.append(sw)
		SKM.append({"n": nm, "p": 150 + z * 40, "t": t, "cnt": cnt, "d": dm, "v": v, "c": cd, "col": colr, "f": fl, "x": WP.size() - 1, "desc": "%d peluru · %d dmg · CD %ds" % [cnt, dm, cd]})

func wi(n: String) -> int:
	for i in range(WP.size()):
		if WP[i].name == n:
			return i
	return -1

func wr(q: float = 0.0) -> int:
	var t := randf() * 100.0
	var r := 0
	while r < 4:
		t -= RW[r]
		if t < 0.0:
			break
		r += 1
	if r < 4 and q > 0.0 and randf() < q * .22:
		r += 1
	var a: Array = WB[r]
	return a[int(randf() * a.size())]

func rl(wc: float, q: float) -> Item:
	var it := Item.new()
	if randf() < wc:
		it.k = "w"
		it.w = wr(q)
	else:
		var u := randf()
		if u < .5:
			it.k = "h"
		elif u < .85:
			it.k = "s"
		else:
			it.k = "k"
	return it

# ---------------------------------------------------------------- simpan / muat
func sv():
	var f = FileAccess.open("user://abr.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(S))

func ld():
	if not FileAccess.file_exists("user://abr.json"):
		return
	var f = FileAccess.open("user://abr.json", FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if typeof(d) == TYPE_DICTIONARY:
		for k in d:
			S[k] = d[k]
	S["co"] = int(S["co"])
	S["w"] = int(S["w"])
	S["a"] = int(S["a"])
	S["m"] = int(S["m"])
	S["sk"] = int(S["sk"])

func pay(k: int, r: int) -> int:
	var c := k * 50 + maxi(0, 70 - r) * 2 + (150 if r == 1 else 0)
	S["co"] += c
	sv()
	return c

# ---------------------------------------------------------------- audio (sintesis prosedural)
func newbuf(d: float):
	_buf = PackedFloat32Array()
	_buf.resize(int(d * SRATE))

func tone(f: float, f2: float, d: float, ty: String, v: float, t0: float = 0.0):
	var n0 := int(t0 * SRATE)
	var n := int(d * SRATE)
	var ph := 0.0
	for k in range(n):
		if n0 + k >= _buf.size():
			break
		var t := float(k) / SRATE
		var fr := f
		if f2 > 0.0:
			fr = f * pow(f2 / f, t / d)
		ph += fr / SRATE
		var fp := ph - floorf(ph)
		var wv := 0.0
		if ty == "sine":
			wv = sin(TAU * ph)
		elif ty == "square":
			wv = 1.0 if fp < .5 else -1.0
		elif ty == "sawtooth":
			wv = 2.0 * fp - 1.0
		else:
			wv = 4.0 * absf(fp - .5) - 1.0
		_buf[n0 + k] += wv * v * pow(.001 / v, t / d)

func noise(d: float, v: float, fc: float, t0: float = 0.0):
	var n0 := int(t0 * SRATE)
	var n := int(d * SRATE)
	var w0 := TAU * minf(fc, SRATE * .45) / SRATE
	var al := sin(w0) / 2.0
	var b0 := al
	var b2 := -al
	var a0 := 1.0 + al
	var a1 := -2.0 * cos(w0)
	var a2 := 1.0 - al
	var x1 := 0.0
	var x2 := 0.0
	var y1 := 0.0
	var y2 := 0.0
	for k in range(n):
		if n0 + k >= _buf.size():
			break
		var x := randf() * 2.0 - 1.0
		var y := (b0 * x + b2 * x2 - a1 * y1 - a2 * y2) / a0
		x2 = x1
		x1 = x
		y2 = y1
		y1 = y
		var t := float(k) / SRATE
		_buf[n0 + k] += y * v * 2.0 * pow(.001 / v, t / d)

func finish(loop: bool = false) -> AudioStreamWAV:
	var n := _buf.size()
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in range(n):
		bytes.encode_s16(i * 2, int(clampf(_buf[i], -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = SRATE
	w.stereo = false
	w.data = bytes
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = n
	return w

func render(spec: Array) -> AudioStreamWAV:
	newbuf(spec[0])
	for i in range(1, spec.size()):
		var o: Array = spec[i]
		if o[0] == "t":
			tone(o[1], o[2], o[3], o[4], o[5], o[6])
		else:
			noise(o[1], o[2], o[3], o[4])
	return finish(false)

func mf(n: int) -> float:
	return 440.0 * pow(2.0, (n - 69) / 12.0)

func mk_music(level: int) -> AudioStreamWAV:
	var bpm := 92.0
	if level == 1:
		bpm = 124.0
	elif level > 1:
		bpm = 150.0
	var sp := 30.0 / bpm
	var CH := [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
	var ARP := [0, 1, 2, 1, 0, 2, 1, 2]
	newbuf(sp * 32.0)
	for stp in range(32):
		var c: Array = CH[(stp >> 3) & 3]
		var k := stp & 7
		var t0 := stp * sp
		if k % 4 == 0:
			tone(mf(c[0] - 24), 0.0, sp * 3.8, "sawtooth", .09, t0)
		if level > 0:
			tone(mf(c[ARP[k]] + 12), 0.0, sp * .9, "square", .035, t0)
			if k % 4 == 0:
				tone(130.0, 45.0, .15, "sine", .25, t0)
			if k % 4 == 2:
				noise(.1, .12, 2500.0, t0)
			if level > 1 or k % 2 == 1:
				noise(.03, .04, 8000.0, t0)
		else:
			tone(mf(c[ARP[k]] + 12), 0.0, sp * .9, "triangle", .05, t0)
	return finish(true)

func ainit():
	if AC_ok:
		return
	AC_ok = true
	for i in range(10):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfxp.append(p)
	musp = AudioStreamPlayer.new()
	musp.volume_db = -8.0
	add_child(musp)
	var T := {
		"f0": [.2, ["t", 300, 1100, .18, "sine", .3, 0]],
		"f1": [.35, ["t", 600, 90, .3, "triangle", .3, 0], ["n", .2, .15, 1200, 0]],
		"f2": [.16, ["n", .14, .35, 1400, 0]],
		"f3": [.16, ["n", .14, .6, 1800, 0], ["t", 160, 40, .12, "square", .3, 0]],
		"f4": [.18, ["n", .16, .35, 700, 0]],
		"f5": [.22, ["t", 1400, 180, .2, "square", .18, 0]],
		"f6": [.35, ["t", 180, 700, .3, "sawtooth", .18, 0], ["n", .2, .2, 900, 0]],
		"hit": [.12, ["t", 220, 80, .1, "square", .2, 0]],
		"hurt": [.3, ["t", 160, 50, .25, "sawtooth", .35, 0], ["n", .12, .3, 500, 0]],
		"die": [.55, ["t", 300, 40, .5, "sawtooth", .3, 0], ["n", .3, .3, 400, 0]],
		"pick": [.2, ["t", 700, 0, .08, "square", .12, 0], ["t", 1050, 0, .12, "square", .12, .07]],
		"sk": [.45, ["t", 200, 1200, .4, "sine", .3, 0], ["n", .3, .2, 3000, 0]],
		"med": [.4, ["t", 500, 800, .2, "sine", .25, 0], ["t", 800, 0, .2, "sine", .2, .15]],
		"jp": [.55, ["n", .5, .3, 600, 0]],
		"tap": [.07, ["t", 900, 0, .05, "square", .1, 0]],
		"warn": [1.1, ["t", 660, 0, .25, "square", .2, 0], ["t", 660, 0, .25, "square", .2, .4], ["t", 660, 0, .25, "square", .2, .8]],
		"win": [.8, ["t", 523, 0, .3, "square", .2, 0], ["t", 659, 0, .3, "square", .2, .15], ["t", 784, 0, .3, "square", .2, .3], ["t", 1047, 0, .3, "square", .2, .45]]}
	for k in T:
		sfxs[k] = render(T[k])

func sfx(k: String, x: float = NAN, y: float = NAN):
	if not AC_ok or mut or not sfxs.has(k):
		return
	var v := 1.0
	if not is_nan(x) and not ents.is_empty():
		var d := hyp(x - ents[0].x, y - ents[0].y)
		v = maxf(0.0, 1.0 - d / 1100.0)
		v *= v
		if v < .02:
			return
	var p: AudioStreamPlayer = sfxp[sfxi % sfxp.size()]
	sfxi += 1
	p.stream = sfxs[k]
	p.volume_db = linear_to_db(v)
	p.play()

func music_tick():
	if not AC_ok:
		return
	var lvl := 0
	if playing and not ents.is_empty() and not over:
		if ents[0].st != 0:
			lvl = 2 if Z.ph >= 4 else 1
	if lvl != cur_mi:
		cur_mi = lvl
		if not mus.has(lvl):
			mus[lvl] = mk_music(lvl)
		musp.stream = mus[lvl]
		musp.play()
	musp.stream_paused = mut

# ---------------------------------------------------------------- dunia
func gt(x: float, y: float) -> int:
	if x < 0.0 or y < 0.0:
		return 0
	var i := int(x / 50.0)
	var j := int(y / 50.0)
	if i >= GN or j >= GN:
		return 0
	return GR[j * GN + i]

func land(x: float, y: float) -> bool:
	return x > 0.0 and y > 0.0 and x < W and y < W and gt(x, y) > 0

func gl(x: float, y: float) -> bool:
	return x > 0.0 and y > 0.0 and x < W and y < W and gt(x, y) >= 2

func add_box(b: Box):
	walls.append(b)
	for i in range(int(b.x / 250.0), int((b.x + b.w) / 250.0) + 1):
		for j in range(int(b.y / 250.0), int((b.y + b.h) / 250.0) + 1):
			var key := i * 128 + j
			if not bk.has(key):
				bk[key] = []
			bk[key].append(b)

func pbox(x: float, y: float, w: float, h: float, f: int):
	var b := Box.new()
	b.x = x
	b.y = y
	b.w = w
	b.h = h
	b.f = f
	add_box(b)

func pdoor(x: float, y: float, w: float, h: float, f: int):
	var b := Box.new()
	b.x = x
	b.y = y
	b.w = w
	b.h = h
	b.f = f
	DR.append(b)

func bb_add(b: Box):
	B.append(b)
	for i in range(int((b.x - 50.0) / 250.0), int((b.x + b.w + 50.0) / 250.0) + 1):
		for j in range(int((b.y - 50.0) / 250.0), int((b.y + b.h + 50.0) / 250.0) + 1):
			var key := i * 128 + j
			if not BBK.has(key):
				BBK[key] = []
			BBK[key].append(b)

func in_b(x: float, y: float, m: float) -> bool:
	var a = BBK.get(int(x / 250.0) * 128 + int(y / 250.0))
	if a == null:
		return false
	for b in a:
		if x > b.x - m and x < b.x + b.w + m and y > b.y - m and y < b.y + b.h + m:
			return true
	return false

func in_m(x: float, y: float) -> bool:
	for m in MN:
		if x > m.x and x < m.x + m.w and y > m.y and y < m.y + m.h:
			return true
	return false

func add_deco(x: float, y: float, r: float, k: int, s: int):
	var key := int(x / 250.0) * 128 + int(y / 250.0)
	if not deco.has(key):
		deco[key] = []
	deco[key].append([x, y, r, k, s])

func side(x: float, y: float, l: float, hz: bool, d: bool, f: int = 2):
	var T := 14.0
	if not d:
		if hz:
			pbox(x, y, l, T, f)
		else:
			pbox(x, y, T, l, f)
		return
	var o := l * .2 + sr() * (l * .6 - 84.0)
	var c := l - o - 84.0
	if hz:
		pdoor(x + o, y - 7.0, 84.0, T + 14.0, f)
		pbox(x, y, o, T, f)
		pbox(x + o + 84.0, y, c, T, f)
	else:
		pdoor(x - 7.0, y + o, T + 14.0, 84.0, f)
		pbox(x, y, T, o, f)
		pbox(x, y + o + 84.0, T, c, f)

func lp(x: float, y: float, w: float, h: float, f: int, wc: float, q: float):
	for t in range(8):
		var px := x + 30.0 + sr() * (w - 60.0)
		var py := y + 30.0 + sr() * (h - 60.0)
		if not blocked(px, py, f):
			loot.append({"x": px, "y": py, "fl": f, "wc": wc, "q": q})
			return

func nf(x: float, y: float) -> float:
	var v := 0.0
	for f in FA:
		v += f[4] * sin(x * f[2] + f[0]) * cos(y * f[3] + f[1])
	return v

func gen_world(sd: String):
	rng.seed = sd.hash()
	DR = []
	walls = []
	bk = {}
	B = []
	BBK = {}
	deco = {}
	loot = []
	MN = []
	FA = []
	for k in range(7):
		var m := 1.0 + k * .5
		var pa := sr() * 6.28
		var pb := sr() * 6.28
		var fa := (.0004 + sr() * .0007) * m
		var fb := (.0004 + sr() * .0007) * m
		FA.append([pa, pb, fa, fb, 1.0 / (1.0 + k * .6)])
	GR = PackedByteArray()
	GR.resize(GN * GN)
	BRI = PackedByteArray()
	BRI.resize(GN * GN)
	var n0 := 2
	if sr() < .45:
		n0 = 3
	var r0 := sr() * 6.28
	IC = []
	for k2 in range(n0):
		var ang := r0 + k2 * 6.28 / n0
		if n0 == 2:
			IC.append([W / 2.0 + cos(ang) * 5100.0, W / 2.0 + sin(ang) * 5100.0, 6900.0])
		else:
			IC.append([W / 2.0 + cos(ang) * 5400.0, W / 2.0 + sin(ang) * 5400.0, 6000.0])
	for j in range(GN):
		for i in range(GN):
			var x := i * 50.0 + 25.0
			var y := j * 50.0 + 25.0
			var mm := -9.0
			var k0 := 0
			for kk in range(n0):
				var c = IC[kk]
				var q = 1.0 - hyp(x - c[0], y - c[1]) / c[2] * 1.15
				if q > mm:
					mm = q
					k0 = kk
			var v := nf(x, y) * .55 + mm * 1.2
			var bsn := sin(x * .0011) + cos(y * .0013)
			var val := 2
			if v < .3:
				val = 0
			elif v < .42:
				val = 1
			elif k0 == n0 - 1:
				val = 5
			elif bsn > 1.1:
				val = 4
			elif bsn > .2:
				val = 3
			GR[j * GN + i] = val
	# jembatan antar pulau
	BE = []
	for kb in range(n0 - 1):
		var A = IC[kb]
		var C = IC[kb + 1]
		var L = hyp(C[0] - A[0], C[1] - A[1])
		var dx = (C[0] - A[0]) / L
		var dy = (C[1] - A[1]) / L
		var ta = 0.0
		var tb = L
		var best = 0.0
		var s0 = -1.0
		var t = 0.0
		while t <= L:
			var wt = gt(A[0] + dx * t, A[1] + dy * t) < 2
			if wt and s0 < 0.0:
				s0 = t
			if (not wt or t + 20.0 > L) and s0 >= 0.0:
				if t - s0 > best:
					best = t - s0
					ta = maxf(0.0, s0 - 20.0)
					tb = minf(L, t + 20.0)
				s0 = -1.0
			t += 20.0
		var u = ta
		while u <= tb:
			for o in range(-1, 2):
				var bx = A[0] + dx * u - dy * o * 50.0
				var by = A[1] + dy * u + dx * o * 50.0
				if bx >= 0.0 and by >= 0.0 and int(bx / 50.0) < GN and int(by / 50.0) < GN:
					var qi = int(by / 50.0) * GN + int(bx / 50.0)
					if GR[qi] < 2:
						GR[qi] = 1
						BRI[qi] = kb + 1
			u += 20.0
		BE.append({"a": Vector2(A[0] + dx * (ta - 30.0), A[1] + dy * (ta - 30.0)), "b": Vector2(A[0] + dx * (tb + 30.0), A[1] + dy * (tb + 30.0))})
	# markas militer (2 lantai, tangga)
	for km in range(n0):
		var ok := false
		var tries := 0
		while tries < 80 and not ok:
			tries += 1
			var c2 = IC[km]
			var w := 760.0
			var h := 560.0
			var x: float = c2[0] + (sr() - .5) * 4400.0 - w / 2.0
			var y: float = c2[1] + (sr() - .5) * 4400.0 - h / 2.0
			if x < 100.0 or y < 100.0 or x + w > W - 100.0 or y + h > W - 100.0:
				continue
			var bad := false
			var aa := -60.0
			while aa <= w + 60.0:
				var bb := -60.0
				while bb <= h + 60.0:
					if gt(x + aa, y + bb) < 2:
						bad = true
					bb += 100.0
				aa += 100.0
			if bad:
				continue
			ok = true
			var mb := Box.new()
			mb.x = x
			mb.y = y
			mb.w = w
			mb.h = h
			mb.c = hsl(float(int(sr() * 360.0)), .22, .32)
			mb.m = true
			mb.sx = x + 30.0
			mb.sy = y + 30.0
			mb.sw = 70.0
			mb.sh = 110.0
			bb_add(mb)
			MN.append(mb)
			side(x, y, w, true, true)
			side(x, y + h - 14.0, w, true, true)
			side(x, y, h, false, true)
			side(x + w - 14.0, y, h, false, true)
			side(x + w * .5, y + 14.0, h - 28.0, false, true, 0)
			side(x + 14.0, y + h * .55, w - 28.0, true, true, 1)
			side(x + w * .62, y + 14.0, h * .55 - 14.0, false, true, 1)
			for qq in range(6):
				lp(x, y, w, h, 0, .6, 1.0)
				lp(x, y, w, h, 1, .7, 2.0)
	# rumah-rumah
	for gx in range(26):
		for gy in range(26):
			var big := sr() < .2
			var w2 := 480.0
			if not big:
				w2 = float(int(230.0 + sr() * 180.0))
			var h2 := 390.0
			if not big:
				h2 = float(int(190.0 + sr() * 150.0))
			var x2 := gx * 760.0 + 30.0 + sr() * (700.0 - w2)
			var y2 := gy * 760.0 + 30.0 + sr() * (700.0 - h2)
			var skip := sr() < .3
			var r1 := sr() < .6
			var r2 := sr() < .6
			var colr := hsl(float(int(sr() * 360.0)), .28, .40)
			if skip:
				continue
			var bad2 := false
			for q in B:
				if x2 < q.x + q.w + 60.0 and x2 + w2 > q.x - 60.0 and y2 < q.y + q.h + 60.0 and y2 + h2 > q.y - 60.0:
					bad2 = true
					break
			if not bad2:
				for pp in [[0.0, 0.0], [w2, 0.0], [0.0, h2], [w2, h2], [w2 / 2.0, h2 / 2.0]]:
					if gt(x2 + pp[0], y2 + pp[1]) < 2:
						bad2 = true
						break
			if bad2:
				continue
			var hb := Box.new()
			hb.x = x2
			hb.y = y2
			hb.w = w2
			hb.h = h2
			hb.c = colr
			bb_add(hb)
			side(x2, y2, w2, true, r1)
			side(x2, y2 + h2 - 14.0, w2, true, true)
			side(x2, y2, h2, false, true)
			side(x2 + w2 - 14.0, y2, h2, false, r2)
			var ly := int(sr() * 4.0)
			if big or ly == 1:
				side(x2 + w2 * (.35 + sr() * .3), y2 + 14.0, h2 - 28.0, false, true)
			if ly == 2 or (big and sr() < .5):
				side(x2 + 14.0, y2 + h2 * (.35 + sr() * .3), w2 - 28.0, true, true)
			var nl := 5 if big else 2
			for kl in range(nl):
				lp(x2, y2, w2, h2, 0, .4 if big else .28, 1.0 if big else 0.0)
	# dekorasi
	for i3 in range(21000):
		var x3 := sr() * W
		var y3 := sr() * W
		var g3 := gt(x3, y3)
		if g3 >= 2 and not in_b(x3, y3, 45.0):
			var sv3 := 0
			if g3 == 5:
				sv3 = 2
			elif g3 == 3:
				sv3 = 1
			add_deco(x3, y3, 13.0 + sr() * 15.0, 0, sv3)
	for i4 in range(8000):
		var x4 := sr() * W
		var y4 := sr() * W
		if gt(x4, y4) >= 2 and not in_b(x4, y4, 30.0):
			add_deco(x4, y4, 8.0 + sr() * 8.0, 1, 0)
	for i5 in range(15000):
		var x5 := sr() * W
		var y5 := sr() * W
		if gt(x5, y5) >= 1 and not in_b(x5, y5, 10.0):
			add_deco(x5, y5, 3.0, 2, 0)
	for i6 in range(2200):
		var x6 := sr() * W
		var y6 := sr() * W
		if gt(x6, y6) < 2 or in_b(x6, y6, 40.0):
			continue
		var rk := 12.0 + sr() * 14.0
		add_deco(x6, y6, rk, 3, 0)
		pbox(x6 - rk * .7, y6 - rk * .7, rk * 1.4, rk * 1.4, 2)
	# minimap
	var img := Image.create(400, 400, false, Image.FORMAT_RGB8)
	for jj in range(GN):
		for ii in range(GN):
			img.set_pixel(ii, jj, TXC[GR[jj * GN + ii]][0])
	var roadc := hc("#b07a3a")
	for e in BE:
		var p0: Vector2 = e.a * .02
		var p1: Vector2 = e.b * .02
		var steps := int(p0.distance_to(p1)) + 1
		for st in range(steps + 1):
			var pp2 := p0.lerp(p1, float(st) / steps)
			img.fill_rect(Rect2i(int(pp2.x) - 1, int(pp2.y) - 1, 3, 3), roadc)
	var gry := hc("#555d66")
	for b in B:
		img.fill_rect(Rect2i(int(b.x * .02), int(b.y * .02), maxi(1, int(b.w * .02)), maxi(1, int(b.h * .02))), gry)
	var gold_c := hc("#e8c36a")
	for b2 in MN:
		img.fill_rect(Rect2i(int(b2.x * .02) - 2, int(b2.y * .02) - 2, 5, 5), gold_c)
	MM = ImageTexture.create_from_image(img)
	walls.sort_custom(func(a, b): return a.x + a.y + a.w + a.h < b.x + b.y + b.w + b.h)

func blocked(x: float, y: float, f: int = 0) -> bool:
	var a = bk.get(int(x / 250.0) * 128 + int(y / 250.0))
	if a != null:
		for b in a:
			if x > b.x and x < b.x + b.w and y > b.y and y < b.y + b.h and (b.f == 2 or b.f == f):
				return true
	return false

func collide(e, r: float):
	var cx := int(e.x / 250.0)
	var cy := int(e.y / 250.0)
	for i in range(cx - 1, cx + 2):
		for j in range(cy - 1, cy + 2):
			var a = bk.get(i * 128 + j)
			if a == null:
				continue
			for b in a:
				if b.f != 2 and b.f != e.fl:
					continue
				var px := clampf(e.x, b.x, b.x + b.w)
				var py := clampf(e.y, b.y, b.y + b.h)
				var dx: float = e.x - px
				var dy: float = e.y - py
				var d := hyp(dx, dy)
				if d < r:
					if d < .01:
						e.y -= r
						continue
					e.x += dx / d * (r - d)
					e.y += dy / d * (r - d)

func los(a, b) -> bool:
	var d := hyp(b.x - a.x, b.y - a.y)
	var n := int(d / 24.0)
	for i in range(1, n):
		if blocked(a.x + (b.x - a.x) * i / n, a.y + (b.y - a.y) * i / n, a.fl):
			return false
	return true

func ni(x: float, y: float) -> int:
	var b := 0
	var d := 1e9
	for k in range(IC.size()):
		var q := hyp(x - IC[k][0], y - IC[k][1])
		if q < d:
			d = q
			b = k
	return b

func nav(x: float, y: float, tx: float, ty: float) -> Vector2:
	var ci := int(x / 50.0)
	var cj := int(y / 50.0)
	var j := -1
	if ci >= 0 and cj >= 0 and ci < GN and cj < GN:
		j = BRI[cj * GN + ci] - 1
	var b := ni(tx, ty)
	if j >= 0:
		var e = BE[j]
		return e.b if b > j else e.a
	var a := ni(x, y)
	if a == b:
		return Vector2(tx, ty)
	var e2 = BE[a if b > a else a - 1]
	var n: Vector2 = e2.a if b > a else e2.b
	if hyp(n.x - x, n.y - y) < 110.0:
		return e2.b if b > a else e2.a
	return n

func rland() -> Array:
	for i in range(500):
		var x := randf() * W
		var y := randf() * W
		if gt(x, y) >= 2:
			return [x, y]
	return [W / 2.0, W / 2.0]

func lnear(x: float, y: float) -> Array:
	for i in range(50):
		var a := randf() * 6.28
		var d := 300.0 + randf() * 2000.0
		var px := x + cos(a) * d
		var py := y + sin(a) * d
		if gl(px, py) and not blocked(px, py, 0):
			return [px, py]
	return [x, y]

# ---------------------------------------------------------------- permainan
func new_game():
	over = false
	mapOn = false
	em = []
	skcd = 0.0
	bul = []
	fx = []
	feed = []
	items = []
	specT = null
	for p in loot:
		var it := rl(p.wc, p.q)
		it.x = p.x
		it.y = p.y
		it.fl = p.fl
		items.append(it)
	for i in range(300):
		var p2 := rland()
		if not in_b(p2[0], p2[1], 20.0) and not blocked(p2[0], p2[1], 0):
			var it2 := rl(.12, 0.0)
			it2.x = p2[0]
			it2.y = p2[1]
			items.append(it2)
	var A0 = IC[0]
	var A1 = IC[1]
	var L0 := hyp(A1[0] - A0[0], A1[1] - A0[1])
	var sg := 1.0 if randf() < .5 else -1.0
	var dx: float = (A1[0] - A0[0]) / L0 * sg
	var dy: float = (A1[1] - A0[1]) / L0 * sg
	var mx: float = (A0[0] + A1[0]) / 2.0
	var my: float = (A0[1] + A1[1]) / 2.0
	PA = {"sx": mx - dx * PLEN / 2.0, "sy": my - dy * PLEN / 2.0, "dx": dx, "dy": dy, "sp": 800.0}
	pdur = PLEN / PA.sp
	pt = 0.0
	var vt := []
	var t := 0.0
	while t < pdur:
		var x: float = PA.sx + PA.dx * PA.sp * t
		var y: float = PA.sy + PA.dy * PA.sp * t
		for o in [[0.0, 0.0], [600.0, 0.0], [-600.0, 0.0], [0.0, 600.0], [0.0, -600.0]]:
			if gl(x + o[0], y + o[1]):
				vt.append(t)
				break
		t += .25
	if vt.size() > 0:
		tEnd = vt[vt.size() - 1] + 1.0
	else:
		tEnd = pdur
	var ord: Array = range(70)
	ord.shuffle()
	ents = []
	for i2 in range(70):
		var e := Ent.new()
		e.id = i2
		e.human = (i2 == 0)
		if i2 == 0:
			e.nm = "Kamu"
			e.col = hc("#ffd23f")
		else:
			e.nm = NM[i2 % 16] + (str(i2 / 16) if i2 > 15 else "")
			e.col = hsl(float((i2 * 47) % 360), .7, .55)
		e.rt = randf()
		e.sd = 1 if randf() < .5 else -1
		e.ks = int(randf() * 10.0)
		e.sc = 6.0 + randf() * 6.0
		e.bf = 4.0 + randf() * 5.0
		var rp := rland()
		e.tx = rp[0]
		e.ty = rp[1]
		ents.append(e)
	var P: Ent = ents[0]
	if int(S["w"]) >= 0:
		P.w = int(S["w"])
	if int(S["a"]) != 0:
		P.ar = 100.0
	if int(S["m"]) != 0:
		P.mk = 3
	for i3 in range(70):
		var en: Ent = ents[i3]
		if vt.size() > 0:
			var idx := mini(vt.size() - 1, int((ord[i3] + randf()) / 70.0 * vt.size()))
			en.jt = vt[idx]
		else:
			en.jt = pdur - .2
	var z := rland()
	Z = {"cx": (z[0] + W / 2.0) / 2.0, "cy": (z[1] + W / 2.0) / 2.0, "r": 14000.0, "ph": 0, "t": 0.0, "on": false, "wn": false, "nx": 0.0, "ny": 0.0, "nr": 0.0, "fr": 0.0, "fx": 0.0, "fy": 0.0}
	nz()

func nz():
	if Z.ph >= ZR.size():
		return
	var nr: float = ZR[Z.ph]
	var nx := 0.0
	var ny := 0.0
	for i in range(60):
		var a := randf() * 6.28
		var m := randf() * maxf(0.0, Z.r - nr) * .8
		nx = Z.cx + cos(a) * m
		ny = Z.cy + sin(a) * m
		if gt(clampf(nx, 0.0, W - 1.0), clampf(ny, 0.0, W - 1.0)) >= 2:
			break
	Z.nx = nx
	Z.ny = ny
	Z.nr = nr
	Z.fr = Z.r
	Z.fx = Z.cx
	Z.fy = Z.cy

func say(t: String):
	feed.append({"t": 5.0, "s": t})

func alive_count() -> int:
	var n := 0
	for e in ents:
		if e.alive:
			n += 1
	return n

func hurt(o, d: float, s):
	if not o.alive or o.inv > 0.0:
		return
	if d > 1.5:
		sfx("hurt" if o.human else "hit", o.x, o.y)
	if s != null and s.rage > 0.0:
		d *= 1.6
	if s != null and s.ls > 0.0:
		s.hp = minf(100.0, s.hp + d * .4)
	var a := minf(o.ar, d * .6)
	o.ar -= a
	o.hp -= d - a
	if o.hp <= 0.0:
		die(o, s)

func die(o, s):
	o.alive = false
	sfx("die", o.x, o.y)
	if o.w >= 0:
		var it := Item.new()
		it.x = o.x + randf() * 20.0
		it.y = o.y + randf() * 20.0
		it.k = "w"
		it.w = o.w
		it.fl = o.fl
		items.append(it)
	var left := alive_count()
	if s != null and s != o:
		s.kills += 1
		say(s.nm + " mengalahkan " + o.nm)
	else:
		say(o.nm + " tersingkir")
	if o.human:
		lbl_et.text = "Tersingkir! Peringkat #" + str(left + 1)
		lbl_es.text = "Kill: %d · +%d koin" % [o.kills, pay(o.kills, left + 1)]
		pan("end")
		pans["end"].get_child(0).color = Color(0, 0, 0, .33)
	if left == 1 and not over:
		over = true
		var w
		for e in ents:
			if e.alive:
				w = e
		if w.human:
			sfx("win")
			lbl_et.text = "KAMU MENANG!"
			lbl_es.text = "Kill: %d · +%d koin · Winner Winner!" % [w.kills, pay(w.kills, 1)]
		else:
			lbl_et.text = "Pemenang: " + w.nm
			lbl_es.text = "Kamu peringkat #2 atau lebih rendah"
		pan("end")
		pans["end"].get_child(0).color = Color(0, 0, 0, .66)

func fire(e):
	var w: Wpn = WP[e.w]
	e.cd = w.r
	e.sh = .8
	sfx("f" + str(w.cat), e.x, e.y)
	if w.s <= 0.0:
		fx.append({"x": e.x + cos(e.ang) * w.g * .6, "y": e.y + sin(e.ang) * w.g * .6, "r": w.g * .6, "col": w.col, "t": 0.0, "l": .15})
		for o in ents:
			if o != e and o.alive and o.st == 2 and o.fl == e.fl:
				var dx: float = o.x - e.x
				var dy: float = o.y - e.y
				var d := hyp(dx, dy)
				if d < w.g + 16.0 and (absf(fposmod(atan2(dy, dx) - e.ang + 9.42, 6.283) - 3.1416) < w.sp or d < 24.0):
					hurt(o, w.d, e)
		return
	for i in range(w.p):
		var a: float = e.ang + (randf() - .5) * 2.0 * w.sp
		var b := Bul.new()
		b.fl = e.fl
		b.x = e.x + cos(a) * 18.0
		b.y = e.y + sin(a) * 18.0
		b.vx = cos(a) * w.s
		b.vy = sin(a) * w.s
		b.l = w.g / w.s
		b.l0 = b.l
		b.w = e.w
		b.o = e
		b.pierce = w.f.contains("p")
		bul.append(b)

func pick(e, it):
	if it.k == "w":
		if e.w >= 0:
			var d := Item.new()
			d.x = e.x + (randf() - .5) * 60.0
			d.y = e.y + 50.0
			d.k = "w"
			d.w = e.w
			d.nb = true
			d.fl = e.fl
			items.append(d)
		e.w = it.w
	elif it.k == "h":
		e.mk = mini(5, e.mk + 1)
	elif it.k == "k":
		e.ks = int(randf() * 10.0)
		e.sc = minf(e.sc, 4.0)
	else:
		e.ar = minf(100.0, e.ar + 45.0)
	items.erase(it)
	e.pk = 1.2
	if e.human:
		sfx("pick")

func near(e, r: float):
	var b = null
	var bd := r
	for it in items:
		if it.fl == e.fl:
			var d := hyp(it.x - e.x, it.y - e.y)
			if d < bd:
				bd = d
				b = it
	return b

func jump(e):
	if e.human:
		mapOn = false
		sfx("jp")
	e.st = 1
	e.fT = 6.0 if e.human else e.bf
	e.x = PA.sx + PA.dx * PA.sp * pt
	e.y = PA.sy + PA.dy * PA.sp * pt
	if not e.human:
		var p := lnear(e.x, e.y)
		e.tx = p[0]
		e.ty = p[1]

func snap(e):
	if land(e.x, e.y):
		return
	var r := 50.0
	while r < 3000.0:
		var a := 0.0
		while a < 6.28:
			var x: float = e.x + cos(a) * r
			var y: float = e.y + sin(a) * r
			if land(x, y):
				e.x = x
				e.y = y
				return
			a += .4
		r += 50.0

func mv(e, dx: float, dy: float, sp: float, dt: float):
	var ox: float = e.x
	var oy: float = e.y
	var d := hyp(dx, dy)
	if d > 0.0:
		var f := sp * (.5 if e.slow > 0.0 else 1.0) * (1.6 if e.spd > 0.0 else 1.0) / d
		e.x += dx * f * dt
		e.y += dy * f * dt
	collide(e, 16.0)
	e.x = clampf(e.x, 20.0, W - 20.0)
	e.y = clampf(e.y, 20.0, W - 20.0)
	if not land(e.x, e.y):
		if land(e.x, oy):
			e.y = oy
		elif land(ox, e.y):
			e.x = ox
		else:
			e.x = ox
			e.y = oy

func use_sk(e):
	if e.sc > 0.0 or e.st != 2:
		return
	var k: int = e.ks
	var ax := cos(e.ang)
	var ay := sin(e.ang)
	e.sc = float(SKN[k][1])
	sfx("sk", e.x, e.y)
	if k == 0 or k == 5:
		var t := 340.0 if k == 5 else 200.0
		while t > 0.0:
			var x: float = e.x + ax * t
			var y: float = e.y + ay * t
			if land(x, y) and not blocked(x, y, 0):
				e.x = x
				e.y = y
				break
			t -= 20.0
		fx.append({"x": e.x, "y": e.y, "r": 40.0, "col": Color.WHITE, "t": 0.0, "l": .3})
	elif k == 1:
		e.inv = 3.0
	elif k == 2:
		e.hp = minf(100.0, e.hp + 40.0)
	elif k == 3:
		e.spd = 6.0
	elif k == 4:
		fx.append({"x": e.x, "y": e.y, "r": 140.0, "col": hc("#ff9a3c"), "t": 0.0, "l": .35})
		for o in ents:
			if o != e and o.alive and o.st == 2 and hyp(o.x - e.x, o.y - e.y) < 140.0:
				hurt(o, 38.0, e)
	elif k == 6:
		e.rage = 7.0
	elif k == 7:
		e.ls = 7.0
	elif k == 8:
		e.cl = 6.0
	else:
		fx.append({"x": e.x, "y": e.y, "r": 230.0, "col": hc("#7fe3ff"), "t": 0.0, "l": .4})
		for o2 in ents:
			if o2 != e and o2.alive and o2.st == 2 and hyp(o2.x - e.x, o2.y - e.y) < 230.0:
				o2.slow = 3.0

func use_med(e):
	if e.mk > 0 and e.hp < 100.0 and e.hl <= 0.0 and e.st == 2:
		e.mk -= 1
		e.hl = 60.0
		sfx("med", e.x, e.y)

func cast_m(P):
	if not playing or paused or int(S["sk"]) < 0 or skcd > 0.0 or not P.alive or P.st != 2:
		return
	var s = SKM[int(S["sk"])]
	skcd = float(s.c)
	sfx("sk", P.x, P.y)
	var bt = null
	var bd := 700.0
	for o in ents:
		if o != P and o.alive and o.st == 2 and o.fl == P.fl:
			var d := hyp(o.x - P.x, o.y - P.y)
			if d < bd:
				bd = d
				bt = o
	var a: float = P.ang
	if bt != null:
		a = atan2(bt.y - P.y, bt.x - P.x)
	em.append({"o": P, "k": int(S["sk"]), "a": a, "t": 0.0, "i": 0})

func sh_m(m, s, i: int):
	var n: int = s.cnt
	var t: int = s.t
	var o = m.o
	var a: float = m.a
	var v := float(s.v)
	if t == 0:
		a += (float(i) / float(n - 1) - .5) * 1.5
	elif t == 1:
		a += i * 6.283 / n
	elif t == 2:
		a += i * .5
	elif t == 3:
		a += (i % 5) * 1.2566 + floorf(i / 5.0) * .14
	elif t == 4:
		a += sin(i * .8) * .55
	elif t == 5:
		a += sin(i * 91.7) * .6
	elif t == 6:
		a += (1.0 if i % 2 == 1 else -1.0) * sin(i * .35) * .7
	else:
		a += i * .35 + (i % 2) * 3.14
		v *= 1.0 + float(i) / n
	var b := Bul.new()
	b.fl = o.fl
	b.x = o.x + cos(a) * 18.0
	b.y = o.y + sin(a) * 18.0
	b.vx = cos(a) * v
	b.vy = sin(a) * v
	b.l = 640.0 / v
	b.l0 = b.l
	b.w = s.x
	b.o = o
	b.pierce = String(s.f).contains("p")
	bul.append(b)

# ---------------------------------------------------------------- AI bot
func bot(e, dt: float):
	e.rt -= dt
	e.seen -= dt
	if e.rt <= 0.0:
		e.rt = .3 + randf() * .2
		var bd := 1e9
		var bt = null
		var sv_ := false
		for o in ents:
			if o != e and o.alive and o.st == 2 and o.fl == e.fl:
				var dx: float = o.x - e.x
				var dy: float = o.y - e.y
				var d := hyp(dx, dy)
				var vr := 110.0 if o.cl > 0.0 else 430.0
				var see: bool = d < vr and ad(atan2(dy, dx), e.ang) < 1.0 and los(e, o)
				var hear: bool = d < 330.0 if o.sh > 0.0 else d < 90.0
				if (see or hear) and d < bd:
					bd = d
					bt = o
					sv_ = see
		if bt != null:
			e.tg = bt
			e.seen = 2.5
			e.lkx = bt.x
			e.lky = bt.y
		elif e.seen <= 0.0 or (e.tg != null and (not e.tg.alive or hyp(e.tg.x - e.x, e.tg.y - e.y) > 520.0)):
			e.tg = null
		e.vis = (bt != null and sv_)
		e.it = null
		if e.tg == null or e.w < 0:
			var idm := 800.0 if e.w < 0 else 300.0
			var bi = null
			for it in items:
				if it.fl != e.fl:
					continue
				var want := false
				if e.w < 0:
					want = (it.k == "w")
				else:
					want = (it.k == "h" and e.mk < 3) or (it.k == "s" and e.ar < 30.0) or (it.k == "k" and e.sc > 10.0)
				if not want:
					continue
				var d2 := hyp(it.x - e.x, it.y - e.y)
				if d2 < idm and ni(it.x, it.y) == ni(e.x, e.y):
					idm = d2
					bi = it
			e.it = bi
	var mdx := 0.0
	var mdy := 0.0
	var zd := hyp(e.x - Z.cx, e.y - Z.cy)
	if zd > Z.r - 90.0:
		var nv := nav(e.x, e.y, Z.cx, Z.cy)
		mdx = nv.x - e.x
		mdy = nv.y - e.y
		e.ang = atan2(mdy, mdx)
	elif e.tg != null and e.w >= 0 and e.vis:
		var t = e.tg
		var ex: float = t.x - e.x
		var ey: float = t.y - e.y
		var d3 := hyp(ex, ey)
		var rg: float = WP[e.w].g
		e.ang = atan2(ey, ex) + (randf() - .5) * .14
		if d3 > rg * .6:
			mdx = ex
			mdy = ey
		else:
			mdx = -ey * e.sd
			mdy = ex * e.sd
		if e.cd <= 0.0 and d3 < rg * .95:
			fire(e)
	elif e.tg != null and e.w >= 0 and e.seen > 0.0:
		mdx = e.lkx - e.x
		mdy = e.lky - e.y
		e.ang = atan2(mdy, mdx)
		if hyp(mdx, mdy) < 50.0:
			e.tg = null
	elif e.it != null:
		mdx = e.it.x - e.x
		mdy = e.it.y - e.y
		e.ang = atan2(mdy, mdx)
	else:
		if not e.has_wp or hyp(e.wpx - e.x, e.wpy - e.y) < 60.0:
			var wx: float = Z.cx
			var wy: float = Z.cy
			for i in range(30):
				var a: float = e.x + (randf() - .5) * 2400.0
				var b: float = e.y + (randf() - .5) * 2400.0
				if land(a, b) and hyp(a - Z.cx, b - Z.cy) < Z.r - 100.0 and ni(a, b) == ni(e.x, e.y):
					wx = a
					wy = b
					break
			e.has_wp = true
			e.wpx = wx
			e.wpy = wy
		mdx = e.wpx - e.x
		mdy = e.wpy - e.y
		e.ang = atan2(mdy, mdx)
	if e.hl <= 0.0 and e.mk > 0 and e.hp < 55.0 and (not e.vis or e.hp < 35.0):
		use_med(e)
	if e.sc <= 0.0:
		var tt = null
		if e.tg != null and e.vis:
			tt = e.tg
		var dd := 1e9
		if tt != null:
			dd = hyp(tt.x - e.x, tt.y - e.y)
		var k: int = e.ks
		var go := false
		if k == 2:
			go = e.hp < 55.0
		elif k == 8 or k == 1:
			go = e.hp < 60.0 and tt != null
		elif k == 4 or k == 9:
			go = dd < 200.0
		elif k == 0 or k == 5 or k == 3:
			go = tt != null and dd > 200.0
		else:
			go = tt != null and dd < 420.0
		if go:
			use_sk(e)
	e.sk += dt
	if e.sk > .5:
		if hyp(e.x - e.lx, e.y - e.ly) < 10.0 and (mdx != 0.0 or mdy != 0.0):
			e.avT = .8
			e.av = randf() * 6.28
			e.has_wp = false
		e.lx = e.x
		e.ly = e.y
		e.sk = 0.0
	if e.avT > 0.0:
		e.avT -= dt
		mdx = cos(e.av)
		mdy = sin(e.av)
	mv(e, mdx, mdy, 170.0, dt)

# ---------------------------------------------------------------- update
func upd(dt: float):
	var P: Ent = ents[0]
	pt += dt
	var pp := Vector2(PA.sx + PA.dx * PA.sp * pt, PA.sy + PA.dy * PA.sp * pt)
	if not Z.on and pt >= tEnd:
		Z.on = true
	for e in ents:
		if not e.alive:
			continue
		e.cd -= dt
		e.slow -= dt
		e.pk -= dt
		e.sc -= dt
		e.inv -= dt
		e.spd -= dt
		e.rage -= dt
		e.ls -= dt
		e.cl -= dt
		e.sh -= dt
		if e.hl > 0.0:
			var xh := minf(e.hl, 24.0 * dt)
			e.hl -= xh
			e.hp = minf(100.0, e.hp + xh)
		if e.pois > 0.0:
			e.pois -= dt
			hurt(e, 4.0 * dt, null)
		if not e.alive:
			continue
		if e.st == 0:
			e.x = pp.x
			e.y = pp.y
			if (e.human and pt >= tEnd) or (not e.human and pt >= e.jt):
				jump(e)
		elif e.st == 1:
			e.fT -= dt
			var dx := 0.0
			var dy := 0.0
			var sp := 0.0
			if e.human:
				var jmx: float = joy.mx
				var jmy: float = joy.my
				if jmx != 0.0 or jmy != 0.0:
					var vv := iv(jmx, jmy)
					dx = vv.x
					dy = vv.y
				else:
					dx = e.tx - e.x
					dy = e.ty - e.y
				sp = 420.0
			else:
				dx = e.tx - e.x
				dy = e.ty - e.y
				sp = minf(hyp(dx, dy) / maxf(e.fT, .3), 1000.0)
			var d := hyp(dx, dy)
			if d == 0.0:
				d = 1.0
			if d > 20.0 or (e.human and (joy.mx != 0.0 or joy.my != 0.0)):
				e.x += dx / d * sp * dt
				e.y += dy / d * sp * dt
			e.x = clampf(e.x, 20.0, W - 20.0)
			e.y = clampf(e.y, 20.0, W - 20.0)
			if e.fT <= 0.0:
				e.st = 2
				e.cd = .4
				snap(e)
		else:
			e.stc -= dt
			e.im = false
			for m in MN:
				if e.x > m.x and e.x < m.x + m.w and e.y > m.y and e.y < m.y + m.h:
					e.im = true
					if e.stc <= 0.0 and e.x > m.sx and e.x < m.sx + m.sw and e.y > m.sy and e.y < m.sy + m.sh:
						e.fl = 0 if e.fl == 1 else 1
						e.stc = 1.3
						if e.human:
							sfx("tap")
			if not e.im:
				e.fl = 0
			if e.human:
				var mx: float = joy.mx
				var my: float = joy.my
				var mg := hyp(mx, my)
				if mg > 1.0:
					mx /= mg
					my /= mg
				var vm := iv(mx, my)
				if mg > .05:
					e.ang = atan2(vm.y, vm.x)
				mv(e, vm.x, vm.y, 190.0, dt)
			else:
				bot(e, dt)
			if not e.human and e.pk <= 0.0:
				var it = near(e, 26.0)
				if it != null:
					var okp := true
					if it.k == "w":
						okp = e.w < 0 or (not it.nb and WP[it.w].rr > WP[e.w].rr)
					if okp:
						pick(e, it)
			if Z.on:
				var dz := hyp(e.x - Z.cx, e.y - Z.cy)
				if dz > Z.r:
					hurt(e, (2.0 + Z.ph * 2.5) * dt, null)
	if P.alive and P.st == 2:
		var bt = null
		var bd := 1e9
		if P.w >= 0:
			var wq: Wpn = WP[P.w]
			var rr := wq.g + (50.0 if wq.s > 0.0 else 30.0)
			for o in ents:
				if o != P and o.alive and o.st == 2 and o.fl == P.fl:
					var d2 := hyp(o.x - P.x, o.y - P.y)
					if d2 < bd and d2 < rr:
						bd = d2
						bt = o
		if att and P.w >= 0 and P.cd <= 0.0:
			if bt != null:
				P.ang = atan2(bt.y - P.y, bt.x - P.x)
			fire(P)
		if inter:
			inter = false
			var it2 = near(P, 56.0)
			if it2 != null:
				pick(P, it2)
		if ski:
			ski = false
			use_sk(P)
		if med:
			med = false
			use_med(P)
	ski = false
	med = false
	inter = false
	if Z.on and Z.ph < ZR.size():
		Z.t += dt
		if Z.t >= ZD - 5.0 and not Z.wn:
			Z.wn = true
			sfx("warn")
		if Z.t >= ZD:
			var kk := minf(1.0, (Z.t - ZD) / ZS)
			Z.r = lerpf(Z.fr, Z.nr, kk)
			Z.cx = lerpf(Z.fx, Z.nx, kk)
			Z.cy = lerpf(Z.fy, Z.ny, kk)
		if Z.t >= ZD + ZS:
			Z.t = 0.0
			Z.wn = false
			Z.ph += 1
			nz()
	skcd -= dt
	var j := em.size() - 1
	while j >= 0:
		var m = em[j]
		var s = SKM[m.k]
		var dl := 0.0
		if s.t == 2:
			dl = .05
		elif s.t > 2:
			dl = .045
		m.t += dt
		while m.i < s.cnt and m.t >= m.i * dl:
			sh_m(m, s, m.i)
			m.i += 1
		if m.i >= s.cnt or not m.o.alive:
			em.remove_at(j)
		j -= 1
	var bi := bul.size() - 1
	while bi >= 0:
		var b: Bul = bul[bi]
		var w: Wpn = WP[b.w]
		var dead := false
		var n := int(ceil(hyp(b.vx, b.vy) * dt / 10.0))
		var kk2 := 0
		while kk2 < n and not dead:
			kk2 += 1
			b.x += b.vx * dt / n
			b.y += b.vy * dt / n
			if blocked(b.x, b.y, b.fl):
				dead = true
				break
			for o in ents:
				if o != b.o and o.alive and o.st == 2 and o.fl == b.fl and hyp(o.x - b.x, o.y - b.y) < 18.0 and not b.hit.has(o):
					hurt(o, w.d, b.o)
					if w.f.contains("s"):
						o.slow = 2.0
					if w.f.contains("v"):
						o.pois = 4.0
					if b.pierce:
						b.hit[o] = true
					else:
						dead = true
						break
		b.l -= dt
		if w.f.contains("b") and not b.rv and b.l < b.l0 / 2.0:
			b.vx *= -1.0
			b.vy *= -1.0
			b.rv = true
			b.hit.clear()
		if b.l <= 0.0:
			dead = true
		if dead:
			if w.a > 0.0:
				fx.append({"x": b.x, "y": b.y, "r": w.a, "col": w.col, "t": 0.0, "l": .3})
				for o2 in ents:
					if o2 != b.o and o2.alive and o2.st == 2 and hyp(o2.x - b.x, o2.y - b.y) < w.a + 16.0:
						hurt(o2, w.d * .6, b.o)
			bul.remove_at(bi)
		bi -= 1
	var fi := fx.size() - 1
	while fi >= 0:
		fx[fi].t += dt
		if fx[fi].t > fx[fi].l:
			fx.remove_at(fi)
		fi -= 1
	var di := feed.size() - 1
	while di >= 0:
		feed[di].t -= dt
		if feed[di].t <= 0.0:
			feed.remove_at(di)
		di -= 1

func _process(delta: float):
	if playing and not ents.is_empty():
		if not paused:
			upd(minf(.05, delta))
	music_tick()
	queue_redraw()

# ---------------------------------------------------------------- gambar: helper
func txt(s: String, x: float, y: float, size: int = 15, col: Color = Color.WHITE, al: int = 0):
	var wd := 700.0
	var px := x
	var ha := HORIZONTAL_ALIGNMENT_LEFT
	if al == 1:
		px = x - wd / 2.0
		ha = HORIZONTAL_ALIGNMENT_CENTER
	elif al == 2:
		px = x - wd
		ha = HORIZONTAL_ALIGNMENT_RIGHT
	draw_string(font, Vector2(px + 1.0, y + 1.0), s, ha, wd, size, Color(0, 0, 0, .8 * col.a))
	draw_string(font, Vector2(px, y), s, ha, wd, size, col)

func ell(cx: float, cy: float, rx: float, ry: float, col: Color):
	var pts := PackedVector2Array()
	for i in range(20):
		var a := TAU * i / 20.0
		pts.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	draw_colored_polygon(pts, col)

func half(cx: float, cy: float, r: float, col: Color):
	var pts := PackedVector2Array()
	for i in range(13):
		var a := PI + PI * i / 12.0
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	draw_colored_polygon(pts, col)

func qb(p0: Vector2, p1: Vector2, p2: Vector2, n: int, inc_end: bool = true) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var last := n if inc_end else n - 1
	for i in range(1, last + 1):
		var t := float(i) / n
		pts.append(p0.lerp(p1, t).lerp(p1.lerp(p2, t), t))
	return pts

func bbm(x: float, y: float, u: float) -> Transform2D:
	return Transform2D(-.7854, Vector2(1.0, 2.0), 0.0, Vector2(x, y)) * Transform2D(0.0, Vector2(-x, -y - u))

func vis(x: float, y: float, m: float) -> bool:
	return x > V0x - m and x < V1x + m and y > V0y - m and y < V1y + m

func setcur(m: Transform2D):
	cur = m
	draw_set_transform_matrix(cur)

func ovr() -> Dictionary:
	var sz := minf(vw, vh) - 44.0
	return {"S": sz, "x": (vw - sz) / 2.0, "y": (vh - sz) / 2.0 + 10.0}

func draw_wpn(x: float, y: float, a: float, w: Wpn, s: float):
	var saved := cur
	setcur(cur * Transform2D(a, Vector2(s, s), 0.0, Vector2(x, y)))
	var r := w.rr
	var col: Color = RC[r]
	var i := w.ci
	if r >= 3:
		draw_circle(Vector2(22, 0), 24.0 if r > 3 else 19.0, ca(Color(col.r, col.g, col.b, .27)))
	match w.cat:
		0:
			draw_line(Vector2(2, 0), Vector2(34, 0), ca(hc("#6b4a2b")), 4.0)
			draw_line(Vector2(2, 0), Vector2(34, 0), ca(hc("#3d2a16")), 1.0)
			draw_circle(Vector2(37, 0), 6.0 + i * .3, ca(col))
			draw_circle(Vector2(35, -2), 2.0, ca(Color(1, 1, 1, .67)))
		1:
			draw_circle(Vector2(26, 0), 13.0, ca(Color(col.r, col.g, col.b, .4)))
			draw_circle(Vector2(26, 0), 7.0, ca(col))
			draw_arc(Vector2(26, 0), 10.5, .3 + i * .5, 4.0 + i * .5, 20, ca(Color.WHITE), 1.5)
			draw_circle(Vector2(24, -2), 2.3, ca(Color.WHITE))
		2:
			setcur(cur * Transform2D(float(i), Vector2(26, 0)))
			var pts := PackedVector2Array()
			for k in range(8):
				var q := k * .785
				var rr := 5.0 if k % 2 == 1 else 11.0
				pts.append(Vector2(cos(q) * rr, sin(q) * rr))
			draw_colored_polygon(pts, ca(hc("#cfd6de")))
			pts.append(pts[0])
			draw_polyline(pts, ca(hc("#59616b")), 1.5)
			draw_circle(Vector2.ZERO, 3.5, ca(col))
		3:
			draw_rect(Rect2(0, -3.5, 12, 7), ca(hc("#2e333b")))
			draw_rect(Rect2(12, -2.6, 16 + i * 1.5, 5.2), ca(hc("#4a5059")))
			draw_rect(Rect2(7, 3, 4, 7), ca(hc("#1c1f24")))
			draw_rect(Rect2(13, -1, 9, 2), ca(col))
			draw_rect(Rect2(12, -3.5, 16 + i * 1.5, 1), ca(hc("#8b939d")))
			if i % 3 == 0:
				draw_rect(Rect2(16, -6, 8, 3), ca(hc("#1c1f24")))
		4:
			draw_rect(Rect2(2, -2, 10, 4), ca(hc("#6b4a2b")))
			draw_rect(Rect2(11, -7, 3, 14), ca(col))
			if i % 3 == 1:
				draw_rect(Rect2(14, -1.5, 18, 3), ca(hc("#dfe6ee")))
				var bl := PackedVector2Array([Vector2(30, -1), Vector2(34, -11), Vector2(42, -7), Vector2(40, 4), Vector2(32, 2)])
				draw_colored_polygon(bl, ca(hc("#dfe6ee")))
				bl.append(bl[0])
				draw_polyline(bl, ca(hc("#59616b")), 1.0)
			else:
				draw_colored_polygon(PackedVector2Array([Vector2(14, -3), Vector2(38, -1.5), Vector2(44, 0), Vector2(38, 1.5), Vector2(14, 3)]), ca(hc("#e6edf4")))
				draw_rect(Rect2(16, -1, 20, 1), ca(Color.WHITE))
		5:
			draw_rect(Rect2(2, -4.5, 26, 9), ca(hc("#d5dbe3")))
			draw_rect(Rect2(8, -2, 14, 4), ca(hc("#2b3139")))
			draw_rect(Rect2(24, -3.5, 9, 7), ca(col))
			draw_rect(Rect2(30, -1, 3, 2), ca(Color.WHITE))
			draw_rect(Rect2(3, -4.5, 3, 9), ca(Color(col.r, col.g, col.b, .53)))
		_:
			draw_line(Vector2(2, 0), Vector2(32, 0), ca(hc("#d9b24c")), 3.0)
			draw_arc(Vector2(37, 0), 8.0, 1.2, 5.1, 16, ca(col), 3.0)
			draw_circle(Vector2(37, 0), 3.5, ca(col))
	setcur(saved)

func draw_e(e, P):
	if not e.alive or e.st == 0:
		return
	var f := 1.0
	var y: float = e.y
	if e.st == 1:
		f = 1.0 + e.fT * .1
		y = e.y - e.fT * 16.0
	var al := .25 if (e.cl > 0.0 and e != P) else 1.0
	ga = al
	if e.st == 1:
		ell(e.x, e.y + 6.0, 14.0, 7.0, Color(0, 0, 0, .27 * al))
		half(e.x, y - 30.0, 24.0, Color(1, 1, 1, .85 * al))
	var c: Color = e.col
	draw_circle(Vector2(e.x, y), 16.0 * f, Color(c.r, c.g, c.b, al))
	draw_arc(Vector2(e.x, y), 16.0 * f, 0.0, TAU, 24, Color(0, 0, 0, .67 * al), 2.0)
	draw_circle(Vector2(e.x - 4.0 * f, y - 5.0 * f), 9.0 * f, Color(1, 1, 1, .19 * al))
	if e.inv > 0.0:
		draw_arc(Vector2(e.x, y), 23.0, 0.0, TAU, 24, Color(.5, .89, 1.0, al), 3.0)
	if e.st == 2:
		if e.w >= 0:
			draw_wpn(e.x + cos(e.ang) * 6.0, y + sin(e.ang) * 6.0, e.ang, WP[e.w], .8)
		draw_circle(Vector2(e.x + cos(e.ang) * 8.0, y + sin(e.ang) * 8.0), 4.0, Color(1, 1, 1, al))
		if e != P:
			draw_rect(Rect2(e.x - 18.0, y - 28.0, 36.0, 5.0), Color(0, 0, 0, .67 * al))
			draw_rect(Rect2(e.x - 18.0, y - 28.0, 36.0 * maxf(0.0, e.hp) / 100.0, 5.0), Color(.29, .87, .5, al))
			if e.ar > 0.0:
				draw_rect(Rect2(e.x - 18.0, y - 32.0, 36.0 * e.ar / 100.0, 3.0), Color(.38, .65, .98, al))
	ga = 1.0

func de(e, P):
	if not iso:
		draw_e(e, P)
		return
	if not e.alive or e.st == 0:
		return
	draw_circle(Vector2(e.x, e.y), 15.0, Color(0, 0, 0, .4))
	var a: float = e.ang
	e.ang = atan2(.5 * sin(a + .7854), cos(a + .7854))
	var saved := cur
	setcur(saved * bbm(e.x, e.y, 14.0))
	draw_e(e, P)
	setcur(saved)
	e.ang = a

func draw_doors(cfl: int):
	var a := .65 + .35 * sin(Time.get_ticks_msec() / 220.0)
	for d in DR:
		if (d.f == 2 or d.f == cfl) and vis(d.x, d.y, 90.0):
			draw_rect(Rect2(d.x, d.y, d.w, d.h), Color(.478, .29, .118, a))
			draw_rect(Rect2(d.x, d.y, d.w, d.h), Color(1, .824, .247, a), false, 3.0)

func draw_ship():
	var x: float = PA.sx + PA.dx * PA.sp * pt
	var y: float = PA.sy + PA.dy * PA.sp * pt
	var a: float = atan2(PA.dy, PA.dx)
	var saved := cur
	for k in range(2):
		var off := Vector2(x, y)
		if k == 0:
			off += Vector2(50, 70)
		setcur(saved * Transform2D(a, off))
		var shadow := (k == 0)
		var cw := Color(0, 0, 0, .22) if shadow else hc("#e9e3cf")
		for sy in [-70.0, 70.0]:
			ell(10.0, sy, 70.0, 16.0, cw)
		var body := PackedVector2Array([Vector2(130, 0)])
		body.append_array(qb(Vector2(130, 0), Vector2(70, 52), Vector2(-100, 40), 12))
		body.append(Vector2(-120, 0))
		body.append(Vector2(-100, -40))
		body.append_array(qb(Vector2(-100, -40), Vector2(70, -52), Vector2(130, 0), 12, false))
		draw_colored_polygon(body, Color(0, 0, 0, .22) if shadow else hc("#7a4a22"))
		if not shadow:
			var inner := PackedVector2Array([Vector2(105, 0)])
			inner.append_array(qb(Vector2(105, 0), Vector2(60, 34), Vector2(-90, 27), 10))
			inner.append(Vector2(-100, 0))
			inner.append(Vector2(-90, -27))
			inner.append_array(qb(Vector2(-90, -27), Vector2(60, -34), Vector2(105, 0), 10, false))
			draw_colored_polygon(inner, hc("#a8743a"))
			for i in range(-80, 90, 20):
				draw_line(Vector2(i, -28), Vector2(i, 28), hc("#5a3414"), 2.0)
			for q in range(ents.size() - 1, -1, -1):
				var e: Ent = ents[q]
				if e.alive and e.st == 0:
					var pp := Vector2(-75 + (e.id * 17) % 150, -18 + (e.id * 7) % 36)
					draw_circle(pp, 9.0 if e.human else 6.0, e.col)
					if e.human:
						draw_arc(pp, 9.0, 0.0, TAU, 16, Color.WHITE, 3.0)
	setcur(saved)

# ---------------------------------------------------------------- gambar utama
func _draw():
	var sz := get_viewport_rect().size
	vw = sz.x
	vh = sz.y
	if not playing or ents.is_empty():
		return
	setcur(Transform2D.IDENTITY)
	draw_rect(Rect2(0, 0, vw, vh), hc("#10161e"))
	var P: Ent = ents[0]
	var ship := (P.st == 0 and P.alive)
	if ship and mapOn:
		draw_overview(P)
		draw_ui(P, 0.0, 0.0)
		return
	var c = null
	var cpx := 0.0
	var cpy := 0.0
	var cfl := 0
	if ship:
		cpx = PA.sx + PA.dx * PA.sp * pt
		cpy = PA.sy + PA.dy * PA.sp * pt
	else:
		if P.alive:
			c = P
		else:
			if specT == null or not specT.alive:
				specT = null
				for e in ents:
					if e.alive:
						specT = e
						break
				if specT == null:
					specT = P
			c = specT
		cpx = c.x
		cpy = c.y
		cfl = c.fl
	var s := vh / (1100.0 if ship else 540.0)
	var cx := cpx - vw / 2.0 / s
	var cy := cpy - vh / 2.0 / s
	V0x = cx
	V0y = cy
	V1x = cx + vw / s
	V1y = cy + vh / s
	var base: Transform2D
	if iso:
		var rr := hyp(vw / 2.0 / s, vh / s) + 90.0
		V0x = cpx - rr
		V0y = cpy - rr
		V1x = cpx + rr
		V1y = cpy + rr
		base = Transform2D(0.0, Vector2(s, s), 0.0, Vector2.ZERO) * Transform2D(0.0, Vector2(vw / 2.0 / s, vh / 2.0 / s)) * Transform2D(0.0, Vector2(1.0, .5), 0.0, Vector2.ZERO) * Transform2D(.7854, Vector2.ZERO) * Transform2D(0.0, Vector2(-cpx, -cpy))
	else:
		base = Transform2D(0.0, Vector2(s, s), 0.0, Vector2.ZERO) * Transform2D(0.0, Vector2(-cx, -cy))
	setcur(base)
	# tanah
	var bt1 := hc("#9a6a35")
	var bt2 := hc("#4a2c10")
	for i in range(maxi(0, int(V0x / 50.0)), mini(GN - 1, int(V1x / 50.0)) + 1):
		for j in range(maxi(0, int(V0y / 50.0)), mini(GN - 1, int(V1y / 50.0)) + 1):
			var q := j * GN + i
			if BRI[q] > 0:
				draw_rect(Rect2(i * 50, j * 50, 51, 51), bt1)
				for yy in [9, 19, 29, 39, 49]:
					draw_rect(Rect2(i * 50, j * 50 + yy, 51, 1), bt2)
			else:
				draw_rect(Rect2(i * 50, j * 50, 51, 51), TXC[GR[q]][(i * 7 + j * 13) % 3])
	if iso:
		draw_doors(cfl)
	# lantai bangunan
	for b in B:
		if vis(b.x + b.w / 2.0, b.y + b.h / 2.0, 400.0):
			draw_rect(Rect2(b.x - 30.0, b.y - 30.0, b.w + 60.0, b.h + 60.0), hc("#8a9199"))
			draw_rect(Rect2(b.x, b.y, b.w, b.h), hc("#7b2d3b") if (b.m and cfl == 1) else hc("#b9aa90"))
			if b.m:
				draw_rect(Rect2(b.sx, b.sy, b.sw, b.sh), hc("#5a3a1a"))
				var yy2: float = b.sy + 4.0
				while yy2 < b.sy + b.sh - 4.0:
					draw_rect(Rect2(b.sx + 3.0, yy2, b.sw - 6.0, 6.0), hc("#b88a52"))
					yy2 += 10.0
	# kumpulkan dekorasi yang terlihat
	var dl := []
	for i2 in range(maxi(0, int((V0x - 40.0) / 250.0)), int((V1x + 40.0) / 250.0) + 1):
		for j2 in range(maxi(0, int((V0y - 40.0) / 250.0)), int((V1y + 40.0) / 250.0) + 1):
			var arr = deco.get(i2 * 128 + j2)
			if arr != null:
				dl.append(arr)
	for arr1 in dl:
		for d in arr1:
			if d[3] == 1:
				draw_circle(Vector2(d[0], d[1]), d[2], hc("#2f6a34"))
			elif d[3] == 2:
				draw_rect(Rect2(d[0], d[1], 2, 5), hc("#00000022"))
	for arr2 in dl:
		for d2 in arr2:
			if d2[3] == 3:
				draw_circle(Vector2(d2[0], d2[1]), d2[2], hc("#7d838a"))
				draw_circle(Vector2(d2[0] - d2[2] * .25, d2[1] - d2[2] * .25), d2[2] * .5, hc("#a3a9b0"))
	# dinding
	for w in walls:
		if w.x < V1x and w.x + w.w > V0x and w.y < V1y and w.y + w.h > V0y and (w.f == 2 or w.f == cfl):
			if iso:
				var H := 16.0 if w.w == w.h else 38.0
				var x0: float = w.x
				var y0: float = w.y
				var X: float = w.x + w.w
				var Y: float = w.y + w.h
				var k := 1.414
				draw_colored_polygon(PackedVector2Array([Vector2(x0, Y), Vector2(X, Y), Vector2(X - k * H, Y - k * H), Vector2(x0 - k * H, Y - k * H)]), hc("#2e333b"))
				draw_colored_polygon(PackedVector2Array([Vector2(X, y0), Vector2(X, Y), Vector2(X - k * H, Y - k * H), Vector2(X - k * H, y0 - k * H)]), hc("#454b55"))
				draw_rect(Rect2(x0 - k * H, y0 - k * H, w.w, w.h), hc("#7c8592"))
			else:
				draw_rect(Rect2(w.x, w.y, w.w, w.h), hc("#4b4f57"))
	# item
	var saved_it := cur
	for it in items:
		if not vis(it.x, it.y, 20.0):
			continue
		if it.fl != cfl and (it.fl == 1 or in_m(it.x, it.y)):
			continue
		var colr: Color
		if it.k == "w":
			colr = RC[WP[it.w].rr]
		elif it.k == "h":
			colr = hc("#22c55e")
		elif it.k == "k":
			colr = hc("#fbbf24")
		else:
			colr = hc("#3b82f6")
		if iso:
			setcur(saved_it * bbm(it.x, it.y, 8.0))
		var ip := Vector2(it.x, it.y)
		var hr := 15.0
		if it.k == "w":
			hr += WP[it.w].rr * 3.0
		draw_circle(ip, hr, Color(colr.r, colr.g, colr.b, .35))
		draw_circle(ip, 9.0, colr)
		draw_arc(ip, 9.0, 0.0, TAU, 16, Color.WHITE, 1.5)
		if it.k == "w":
			draw_wpn(it.x - 11.0, it.y + 8.0, -.75, WP[it.w], .55)
		else:
			var lt := "S"
			if it.k == "h":
				lt = "+"
			elif it.k == "k":
				lt = "K"
			draw_string(font, Vector2(it.x - 50.0, it.y + 3.5), lt, HORIZONTAL_ALIGNMENT_CENTER, 100.0, 10, Color.BLACK)
		if iso:
			setcur(saved_it)
	# pemain
	for e2 in ents:
		if e2 != c and vis(e2.x, e2.y, 40.0) and (e2.fl == cfl or not e2.im):
			de(e2, P)
	if c != null:
		de(c, P)
	# efek
	for f in fx:
		var k2: float = f.t / f.l
		var fc: Color = f.col
		draw_circle(Vector2(f.x, f.y), f.r * (.4 + .6 * k2), Color(fc.r, fc.g, fc.b, .6 * (1.0 - k2)))
	# peluru
	var saved_b := cur
	for b2 in bul:
		var wq: Wpn = WP[b2.w]
		var q2: Color = wq.col
		var o := -20.0 if iso else 0.0
		draw_line(Vector2(b2.x + o, b2.y + o), Vector2(b2.x + o - b2.vx * .04, b2.y + o - b2.vy * .04), Color(q2.r, q2.g, q2.b, .5), 4.0)
		if iso:
			setcur(saved_b * bbm(b2.x, b2.y, 14.0))
		draw_circle(Vector2(b2.x, b2.y), 2.5 if wq.s > 900.0 else 5.0, q2)
		draw_circle(Vector2(b2.x, b2.y), 1.8, Color.WHITE)
		if iso:
			setcur(saved_b)
	# pohon
	var saved_t := cur
	for arr3 in dl:
		for d3 in arr3:
			if d3[3] != 0:
				continue
			var trr: float = d3[2]
			if iso:
				setcur(saved_t * bbm(d3[0], d3[1], trr + 8.0))
				draw_rect(Rect2(d3[0] - 3.0, d3[1], 6.0, trr + 8.0), hc("#5b3a1a"))
			var tcs: Array = TC[d3[4]]
			var c0: Color = tcs[0]
			var c1: Color = tcs[1]
			draw_circle(Vector2(d3[0], d3[1]), trr + 4.0, Color(c0.r, c0.g, c0.b, .9))
			draw_circle(Vector2(d3[0] - 3.0, d3[1] - 3.0), trr * .6, Color(c1.r, c1.g, c1.b, .9))
			if iso:
				setcur(saved_t)
	# atap rumah (mode 2D)
	if not iso:
		for b3 in B:
			if vis(b3.x + b3.w / 2.0, b3.y + b3.h / 2.0, 300.0):
				var inn: bool = c != null and c.x > b3.x and c.x < b3.x + b3.w and c.y > b3.y and c.y < b3.y + b3.h
				var aa := .12 if inn else .97
				var rc: Color = b3.c
				draw_rect(Rect2(b3.x - 6.0, b3.y - 6.0, b3.w + 12.0, b3.h + 12.0), Color(rc.r, rc.g, rc.b, aa))
				var ridge := Color(0, 0, 0, .27 * aa)
				if b3.w > b3.h:
					draw_rect(Rect2(b3.x, b3.y + b3.h / 2.0 - 2.0, b3.w, 4.0), ridge)
				else:
					draw_rect(Rect2(b3.x + b3.w / 2.0 - 2.0, b3.y, 4.0, b3.h), ridge)
				if b3.m:
					draw_rect(Rect2(b3.x - 6.0, b3.y - 6.0, b3.w + 12.0, b3.h + 12.0), Color(.91, .765, .416, aa), false, 5.0)
		draw_doors(cfl)
	if pt < pdur + 8.0:
		if iso:
			var sv_c := cur
			setcur(sv_c * Transform2D(0.0, Vector2(-212, -212)))
			draw_ship()
			setcur(sv_c)
		else:
			draw_ship()
	# zona
	draw_zone()
	setcur(Transform2D.IDENTITY)
	# salju
	if gt(cpx, cpy) == 5:
		var T := Time.get_ticks_msec() / 1000.0
		for i3 in range(80):
			var sx := fposmod(i3 * 97.0 + T * 25.0 * (1 + i3 % 3) + sin(T + i3) * 20.0, vw)
			var sy2 := fposmod(i3 * 53.0 + T * 70.0 * (1 + i3 % 2), vh)
			draw_rect(Rect2(sx, sy2, 2.5, 2.5), Color(1, 1, 1, .8))
	draw_ui(P, cpx, cpy)

func draw_zone():
	var r: float = maxf(1.0, Z.r)
	var corners := [Vector2(V0x, V0y), Vector2(V1x, V0y), Vector2(V0x, V1y), Vector2(V1x, V1y)]
	var rb := 0.0
	for p in corners:
		rb = maxf(rb, hyp(p.x - Z.cx, p.y - Z.cy))
	rb += 150.0
	var n := clampi(int(r / 50.0), 64, 300)
	if rb > r:
		var red := Color(.878, .157, .235, .25)
		var pa := Vector2(Z.cx + r, Z.cy)
		var pb := Vector2(Z.cx + rb, Z.cy)
		for k in range(1, n + 1):
			var a := TAU * k / n
			var ca_ := cos(a)
			var sa_ := sin(a)
			var pa2 := Vector2(Z.cx + ca_ * r, Z.cy + sa_ * r)
			var pb2 := Vector2(Z.cx + ca_ * rb, Z.cy + sa_ * rb)
			draw_colored_polygon(PackedVector2Array([pa, pb, pb2, pa2]), red)
			pa = pa2
			pb = pb2
	var ring := clampi(int(r / 40.0), 64, 1024)
	draw_arc(Vector2(Z.cx, Z.cy), r, 0.0, TAU, ring, hc("#4fc3ff"), 4.0)
	if Z.ph < ZR.size() and Z.t < ZD:
		var nn := clampi(int(Z.nr * TAU / 40.0), 32, 400)
		var w1 := Color(1, 1, 1, .85)
		for k2 in range(0, nn, 2):
			var a1 := TAU * k2 / nn
			var a2 := TAU * (k2 + 1) / nn
			draw_line(Vector2(Z.nx + cos(a1) * Z.nr, Z.ny + sin(a1) * Z.nr), Vector2(Z.nx + cos(a2) * Z.nr, Z.ny + sin(a2) * Z.nr), w1, 2.0)

func draw_overview(P):
	var o := ovr()
	var q: float = o.S / W
	draw_texture_rect(MM, Rect2(o.x, o.y, o.S, o.S), false)
	draw_rect(Rect2(o.x, o.y, o.S, o.S), Color.WHITE, false, 2.0)
	var p0 := Vector2(o.x + PA.sx * q, o.y + PA.sy * q)
	var p1 := Vector2(o.x + (PA.sx + PA.dx * PLEN) * q, o.y + (PA.sy + PA.dy * PLEN) * q)
	for i in range(0, 40, 2):
		draw_line(p0.lerp(p1, float(i) / 40.0), p0.lerp(p1, float(i + 1) / 40.0), Color(1, 1, 1, .6), 2.0)
	draw_circle(Vector2(o.x + (PA.sx + PA.dx * PA.sp * pt) * q, o.y + (PA.sy + PA.dy * PA.sp * pt) * q), 7.0, Color.WHITE)
	var tp := Vector2(o.x + P.tx * q, o.y + P.ty * q)
	var red := hc("#ff3b3b")
	draw_arc(tp, 10.0, 0.0, TAU, 20, red, 3.0)
	draw_line(tp + Vector2(-16, 0), tp + Vector2(16, 0), red, 3.0)
	draw_line(tp + Vector2(0, -16), tp + Vector2(0, 16), red, 3.0)
	txt("Ketuk peta untuk memilih tempat mendarat, lalu tekan LOMPAT", vw / 2.0, 20.0, 15, Color.WHITE, 1)
	txt("Pemain: " + str(ents.size()), 14.0, 26.0)

# ---------------------------------------------------------------- HUD + tombol
func bpos(id: String) -> Vector3:
	match id:
		"ba":
			return Vector3(vw - 72.0, vh - 72.0, 48.0)
		"bi":
			return Vector3(vw - 176.0, vh - 66.0, 36.0)
		"bs":
			return Vector3(vw - 60.0, vh - 170.0, 36.0)
		"bm":
			return Vector3(vw - 163.0, vh - 151.0, 33.0)
		"bx":
			return Vector3(vw - 255.0, vh - 62.0, 31.0)
		"ib":
			return Vector3(vw - 167.0, 35.0, 23.0)
		"bz":
			return Vector3(vw - 218.0, 35.0, 20.0)
	return Vector3(vw - 266.0, 35.0, 20.0)

func draw_ui(P, cpx: float, cpy: float):
	setcur(Transform2D.IDENTITY)
	# ---- HUD teks
	txt("Hidup: %d   Kill: %d" % [alive_count(), P.kills], 14.0, 26.0)
	txt("Seed: " + seedV + ("  ·  Lantai 2" if P.fl == 1 else ""), 14.0, 44.0)
	var msg := ""
	if Z.ph >= ZR.size():
		msg = "Zona terakhir!"
	elif not Z.on:
		msg = "Kapal melintas..."
	elif Z.t < ZD:
		msg = "Zona mengecil dalam " + fmt(ZD - Z.t)
	else:
		msg = "Zona sedang mengecil!"
	txt(msg, vw / 2.0, 24.0, 15, Color.WHITE, 1)
	for i in range(feed.size()):
		var f = feed[i]
		txt(f.s, 14.0, 66.0 + i * 17.0, 13, Color(1, 1, 1, minf(1.0, f.t)))
	# ---- minimap
	var mm := 120.0
	var mx := vw - mm - 12.0
	var my := 12.0
	var q := mm / W
	draw_texture_rect(MM, Rect2(mx, my, mm, mm), false, Color(1, 1, 1, .9))
	draw_rect(Rect2(mx, my, mm, mm), Color.WHITE, false, 2.0)
	var N := 128
	var prev := Vector2.ZERO
	var prev_in := false
	for k in range(N + 1):
		var a := TAU * k / N
		var p := Vector2(mx + (Z.cx + cos(a) * Z.r) * q, my + (Z.cy + sin(a) * Z.r) * q)
		var inside := p.x >= mx and p.x <= mx + mm and p.y >= my and p.y <= my + mm
		if k > 0 and inside and prev_in:
			draw_line(prev, p, hc("#4fc3ff"), 1.5)
		prev = p
		prev_in = inside
	draw_circle(Vector2(mx + cpx * q, my + cpy * q), 3.5, hc("#ffd23f"))
	# ---- bar nyawa
	if P.alive and P.st == 2:
		var bw := minf(240.0, vw * .3)
		var bx := (vw - bw) / 2.0
		var by := vh - 46.0
		draw_rect(Rect2(bx - 2.0, by - 2.0, bw + 4.0, 14.0), Color(0, 0, 0, .53))
		draw_rect(Rect2(bx, by, bw * maxf(0.0, P.hp) / 100.0, 10.0), hc("#4ade80"))
		draw_rect(Rect2(bx, by - 8.0, bw * P.ar / 100.0, 5.0), hc("#60a5fa"))
		var wn := "Tangan kosong"
		if P.w >= 0:
			wn = WP[P.w].name + " [" + RN[WP[P.w].rr] + "]"
		var sk_t: String = "Skill: " + str(SKN[P.ks][0])
		if P.sc > 0.0:
			sk_t += " (" + str(int(ceil(P.sc))) + "s)"
		else:
			sk_t += " (siap)"
		txt(wn + "  ·  " + sk_t, vw / 2.0, by + 30.0, 14, Color.WHITE, 1)
		var it = near(P, 56.0)
		if it != null:
			var nm := "Perisai"
			if it.k == "w":
				nm = WP[it.w].name + " [" + RN[WP[it.w].rr] + "]"
			elif it.k == "h":
				nm = "Medkit"
			elif it.k == "k":
				nm = "Orb Skill"
			txt("Ambil: " + nm, vw / 2.0, by - 20.0, 14, Color.WHITE, 1)
	if P.st == 0:
		txt("Kapal udara melintas · ketuk PETA untuk pilih lokasi · LOMPAT untuk terjun", vw / 2.0, 50.0, 15, Color.WHITE, 1)
		var q2 := 120.0 / W
		draw_arc(Vector2(vw - 132.0 + P.tx * q2, 12.0 + P.ty * q2), 5.0, 0.0, TAU, 12, hc("#ff3b3b"), 2.0)
	if P.st == 1:
		txt("Meluncur...  gerakkan joystick untuk mengarahkan", vw / 2.0, 50.0, 15, Color.WHITE, 1)
	# ---- joystick
	var jx: float = joy.bx if joy.on else 90.0
	var jy: float = joy.by if joy.on else vh - 90.0
	var ja := .6 if joy.on else .25
	draw_arc(Vector2(jx, jy), 50.0, 0.0, TAU, 32, Color(1, 1, 1, ja), 3.0)
	draw_circle(Vector2(jx + joy.mx * 50.0, jy + joy.my * 50.0), 22.0, Color(1, 1, 1, ja))
	# ---- tombol
	for id in BTN:
		var b := bpos(id)
		var cc := Vector2(b.x, b.y)
		draw_circle(cc, b.z, BCOL[id])
		draw_arc(cc, b.z - 1.5, 0.0, TAU, 32, Color(1, 1, 1, .55), 3.0)
		var lb := ""
		var fs := 13
		if id == "ba":
			lb = "LOMPAT" if P.st == 0 else "ATK"
		elif id == "bi":
			lb = ("TUTUP" if mapOn else "PETA") if P.st == 0 else "AMBIL"
		elif id == "bs":
			lb = "SKILL" + ((" " + str(int(ceil(P.sc)))) if P.sc > 0.0 else "")
		elif id == "bm":
			lb = "MEDKIT x" + str(P.mk)
			fs = 11
		elif id == "bx":
			fs = 11
			if int(S["sk"]) < 0:
				lb = "-"
			elif skcd > 0.0:
				lb = str(int(ceil(skcd)))
			else:
				lb = "SKILL+"
		elif id == "ib":
			lb = "2D" if iso else "2.5D"
			fs = 12
		if lb != "":
			draw_string(font, Vector2(cc.x - 60.0, cc.y + fs * .35), lb, HORIZONTAL_ALIGNMENT_CENTER, 120.0, fs, Color.WHITE)
		elif id == "bz":
			for oy in [-6.0, 0.0, 6.0]:
				draw_line(Vector2(cc.x - 8.0, cc.y + oy), Vector2(cc.x + 8.0, cc.y + oy), Color.WHITE, 3.0)
		elif id == "mu":
			draw_colored_polygon(PackedVector2Array([Vector2(cc.x - 9, cc.y - 4), Vector2(cc.x - 4, cc.y - 4), Vector2(cc.x + 2, cc.y - 9), Vector2(cc.x + 2, cc.y + 9), Vector2(cc.x - 4, cc.y + 4), Vector2(cc.x - 9, cc.y + 4)]), Color.WHITE)
			if mut:
				draw_line(Vector2(cc.x + 5, cc.y - 5), Vector2(cc.x + 12, cc.y + 5), hc("#ef4444"), 2.5)
				draw_line(Vector2(cc.x + 12, cc.y - 5), Vector2(cc.x + 5, cc.y + 5), hc("#ef4444"), 2.5)
			else:
				draw_arc(Vector2(cc.x + 2, cc.y), 6.0, -.8, .8, 8, Color.WHITE, 2.0)
				draw_arc(Vector2(cc.x + 2, cc.y), 10.0, -.8, .8, 8, Color.WHITE, 2.0)

# ---------------------------------------------------------------- input sentuh (multitouch)
func overlay_on() -> bool:
	for k in pans:
		if pans[k].visible:
			return true
	return false

func _input(ev: InputEvent):
	if not playing or ents.is_empty() or overlay_on():
		return
	if ev is InputEventScreenTouch:
		if ev.pressed:
			touch_down(ev.index, ev.position)
		else:
			touch_up(ev.index)
	elif ev is InputEventScreenDrag:
		touch_move(ev.index, ev.position)

func touch_down(i: int, p: Vector2):
	var P: Ent = ents[0]
	for id in BTN:
		var b := bpos(id)
		if p.distance_to(Vector2(b.x, b.y)) <= b.z + 6.0:
			touches[i] = id
			bpress(id, i)
			return
	if P.st == 0 and not mapOn and p.x > vw - 132.0 and p.y < 134.0:
		mapOn = true
		sfx("tap")
		return
	if P.st == 0 and mapOn:
		var o := ovr()
		if p.x > o.x and p.x < o.x + o.S and p.y > o.y and p.y < o.y + o.S:
			sfx("tap")
			P.tx = (p.x - o.x) / o.S * W
			P.ty = (p.y - o.y) / o.S * W
			return
	if p.x < vw * .5 and not joy.on:
		joy.on = true
		joy.id = i
		joy.bx = p.x
		joy.by = p.y
		joy.mx = 0.0
		joy.my = 0.0

func touch_move(i: int, p: Vector2):
	if i != joy.id:
		return
	var dx: float = p.x - joy.bx
	var dy: float = p.y - joy.by
	var d := hyp(dx, dy)
	var m := minf(d, 50.0)
	if d > 0.0:
		joy.mx = dx / d * m / 50.0
		joy.my = dy / d * m / 50.0
	else:
		joy.mx = 0.0
		joy.my = 0.0

func touch_up(i: int):
	if i == joy.id:
		joy.on = false
		joy.id = -1
		joy.mx = 0.0
		joy.my = 0.0
	if i == att_t:
		att = false
		att_t = -1
	touches.erase(i)

func bpress(id: String, ti: int):
	var P: Ent = ents[0]
	match id:
		"ba":
			if P.st == 0:
				jump(P)
			else:
				att = true
				att_t = ti
		"bi":
			if P.st == 0:
				mapOn = not mapOn
				sfx("tap")
			else:
				inter = true
		"bs":
			ski = true
		"bm":
			med = true
		"bx":
			cast_m(P)
		"ib":
			iso = not iso
		"bz":
			paused = true
			pan("ps")
		"mu":
			mut = not mut

# ---------------------------------------------------------------- UI menu (Control)
func mkpanel(id: String, bg: Color) -> VBoxContainer:
	var root := Control.new()
	ui.add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var r := ColorRect.new()
	r.color = bg
	root.add_child(r)
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cc := CenterContainer.new()
	root.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	cc.add_child(v)
	root.visible = false
	pans[id] = root
	return v

func lab(par, text: String, size: int = 14, width: float = 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	if width > 0.0:
		l.custom_minimum_size = Vector2(width, 0)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	par.add_child(l)
	return l

func btn(par, text: String, cb: Callable, size: int = 14) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.pressed.connect(cb)
	par.add_child(b)
	return b

func hrow(par) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 10)
	par.add_child(h)
	return h

func gold(b: Button):
	var sb := StyleBoxFlat.new()
	sb.bg_color = hc("#ffcc33")
	sb.set_corner_radius_all(30)
	sb.content_margin_left = 30.0
	sb.content_margin_right = 30.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, sb)
	for cn in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(cn, hc("#222222"))

func build_ui():
	ui = CanvasLayer.new()
	add_child(ui)
	var v := mkpanel("con", hc("#162536"))
	lab(v, "ARENA BOLA", 34)
	lab(v, "Sambungkan untuk masuk layar penuh landscape.", 14)
	gold(btn(v, "CONNECT", on_connect, 22))
	v = mkpanel("menu", hc("#162536"))
	lab(v, "ARENA BOLA", 34)
	lbl_cc = lab(v, "", 20)
	var r1 := hrow(v)
	gold(btn(r1, "PLAY", on_play, 22))
	gold(btn(r1, "MARKETPLACE", on_market, 22))
	lab(v, "Joystick kiri = gerak · ATK = serang · AMBIL = ambil item · SKILL = skill orb · SKILL+ = skill marketplace · 2.5D, MENU, dan suara ada di baris atas", 12, 520.0)
	v = mkpanel("pp", hc("#0c1118"))
	lab(v, "PLAY", 26)
	lab(v, "Seed menentukan peta. Kosongkan seed = peta acak di setiap match.", 14, 460.0)
	seed_edit = LineEdit.new()
	seed_edit.placeholder_text = "Seed dunia (kosong = acak)"
	seed_edit.max_length = 24
	seed_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	seed_edit.custom_minimum_size = Vector2(320, 40)
	v.add_child(seed_edit)
	gold(btn(v, "START GAME", start, 22))
	btn(v, "Kembali", tomenu, 14)
	v = mkpanel("mk", hc("#0c1118"))
	lab(v, "MARKETPLACE", 26)
	lbl_mc = lab(v, "", 20)
	var r2 := hrow(v)
	btn(r2, "Barang", tab0, 14)
	btn(r2, "Skill (30)", tab1, 14)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(700, 150)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	sc.add_child(grid)
	btn(v, "Kembali", tomenu, 14)
	v = mkpanel("ps", hc("#0c1118cc"))
	lab(v, "Jeda", 26)
	var r3 := hrow(v)
	gold(btn(r3, "Lanjut", on_resume, 20))
	gold(btn(r3, "Match Lagi", start, 20))
	gold(btn(r3, "Menu", tomenu, 20))
	v = mkpanel("end", hc("#000000aa"))
	lbl_et = lab(v, "", 34)
	lbl_es = lab(v, "", 14, 460.0)
	var r4 := hrow(v)
	gold(btn(r4, "Main Lagi", start, 20))
	gold(btn(r4, "Menu", tomenu, 20))
	v = mkpanel("load", hc("#0c1118"))
	lab(v, "Memuat dunia...", 22)

func pan(id: String):
	for k in pans:
		pans[k].visible = (k == id)
	joy.on = false
	joy.id = -1
	joy.mx = 0.0
	joy.my = 0.0
	att = false
	att_t = -1
	touches.clear()

func on_connect():
	ainit()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	tomenu()

func on_play():
	pan("pp")

func on_market():
	mkr()
	pan("mk")

func on_resume():
	paused = false
	pan("")

func tab0():
	tab = 0
	mkr()

func tab1():
	tab = 1
	mkr()

func tomenu():
	playing = false
	paused = false
	lbl_cc.text = "Koin: %d" % int(S["co"])
	pan("menu")

func start():
	playing = false
	pan("load")
	await get_tree().process_frame
	await get_tree().process_frame
	seedV = seed_edit.text.strip_edges()
	if seedV == "":
		seedV = str(randi() % 1000000000)
	gen_world(seedV)
	new_game()
	pan("")
	paused = false
	playing = true

# ---------------------------------------------------------------- marketplace
func mkr():
	lbl_mc.text = "Koin: %d" % int(S["co"])
	for ch in grid.get_children():
		ch.queue_free()
	var L: Array = SKM if tab == 1 else GEAR
	for i in range(L.size()):
		var x = L[i]
		var key := ("s" if tab == 1 else "g") + str(i)
		var own: bool = S["own"].has(key)
		var eq := false
		if tab == 1:
			eq = (int(S["sk"]) == i)
		elif typeof(x.k) == TYPE_STRING:
			if x.k == "a":
				eq = int(S["a"]) != 0
			else:
				eq = int(S["m"]) != 0
		else:
			eq = (int(S["w"]) == int(x.k))
		var status := "Koin %d" % int(x.p)
		if own:
			status = "DIPAKAI" if eq else "PAKAI"
		var desc: String = x.desc if tab == 1 else x.d
		var b := Button.new()
		b.text = x.n + "\n" + desc + "\n" + status
		b.add_theme_font_size_override("font_size", 11)
		b.custom_minimum_size = Vector2(165, 64)
		if eq:
			b.modulate = hc("#ffcc33")
		b.pressed.connect(buy.bind(i, b))
		grid.add_child(b)

func buy(i: int, b: Button):
	var x = (SKM if tab == 1 else GEAR)[i]
	var key := ("s" if tab == 1 else "g") + str(i)
	if not S["own"].has(key):
		if int(S["co"]) < int(x.p):
			b.modulate = hc("#e5484d")
			return
		S["co"] = int(S["co"]) - int(x.p)
		S["own"][key] = 1
	if tab == 1:
		S["sk"] = -1 if int(S["sk"]) == i else i
	elif typeof(x.k) == TYPE_STRING:
		if x.k == "a":
			S["a"] = 0 if int(S["a"]) != 0 else 1
		else:
			S["m"] = 0 if int(S["m"]) != 0 else 1
	else:
		S["w"] = -1 if int(S["w"]) == int(x.k) else int(x.k)
	sv()
	mkr()
