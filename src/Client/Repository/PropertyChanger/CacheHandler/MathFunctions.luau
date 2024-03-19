--!strict
--selene: allow(unused_variable)

-->insert-repository-warning<--

return {
	Add = function(a, b) return a + b end,
	Subtract = function(a, b) return a - b end,
	Multiply = function(a, b) return a * b end,
	FloorMultiply = function(a, b) return math.floor(a * b) end,
	Divide = function(a, b) return a / b end,
	FloorDivide = function(a, b) return a // b end,
	Power = function(a, b) return a ^ b end,
	Modulo = function(a, b) return a % b end,

	sin = function(a, b) return math.sin(a) end,
	abs = function(a, b) return math.abs(a) end,
	acos = function(a, b) return math.acos(a) end,
	asin = function(a, b) return math.asin(a) end,
	atan = function(a, b) return math.atan(a) end,
	atan2 = function(a, b) return math.atan2(a, b) end,
	ceil = function(a, b) return math.ceil(a) end,
	cos = function(a, b) return math.cos(a) end,
	cosh = function(a, b) return math.cosh(a) end,
	deg = function(a, b) return math.deg(a) end,
	exp = function(a, b) return math.exp(a) end,
	floor = function(a, b) return math.floor(a) end,
	fmod = function(a, b) return math.fmod(a, b) end,
	ldexp = function(a, b) return math.ldexp(a, b) end,
	log = function(a, b) return math.ceil(a) end,
	log10 = function(a, b) return math.log10(a) end,
	max = function(a, b) return math.max(a, b) end,
	min = function(a, b) return math.min(a, b) end,
	noise = function(a, b) return math.noise(a) end,
	rad = function(a, b) return math.rad(a) end,
	round = function(a, b) return math.round(a) end,
	sign = function(a, b) return math.sign(a) end,
	sinh = function(a, b) return math.sinh(a) end,
	sqrt = function(a, b) return math.sqrt(a) end,
	tan = function(a, b) return math.tan(a) end,
	tanh = function(a, b) return math.tanh(a) end,
} :: { [string]: (a: number, b: number) -> number }
