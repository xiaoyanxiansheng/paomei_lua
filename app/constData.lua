local moduleName = "constData"
module(moduleName,package.seeall)
--表示攻击者/防御者
 ATTACKER = 1
 DEFENDER = 2
 --
 LEFTSIDE = 1
 RIGHTSIDE = -1
--技能状态
READY = 0
--状态
 NORMAL = 1
 DEAD = 2
 DIZZY = 3
 SLEEP = 4
 --技能effectType
 DIRECTLYHURT=1
 DIRECTLYHEAL=2
 ADDBUFF=3
 REMOVEBUFF=4
 BLESS=5
 CURSE=6
 REBIRTH=7
 DIRECTLYDEAD=8

statusType = {
[1] = "normal",--正常
[2] = "dead",--死亡
[105] = "dizzy",--晕眩
[4] = "sleep",--睡眠
}

attributeType = {
	[1] = "hp",
	[2] = "hp",
	[5] = "atk",
	[6] = "def",
	[7] = "agi"
}

--属性
 HP = 1
 MAXHP = 2
 RAGE = 3 --怒气
 MAXRAGE = 4
 MAX = 4
 ATK = 5
 DEF = 6
 AGI = 7--速度
--condition
 PREEFFECT = 1 --前置效果
 POSSIBILITY = 2 --触发几率
 DEFAULT = 0
--直接攻击
 EXPORT = 1
 EXPORT_PROPERTY = 2
 PERCENT = 3
 ABSOULTE = 4
 MAXLIMIT = 5
 IMPORT = 6
 IMPORT_PROPERTY = 7
--添加Buff
 BUFFID = 8
 DELAY = 9
 DURATION = 10
 INTERVAL = 11

 --伤害值下限保护
 MINDAMAGE = 0.05

 --输赢
ATTACKER_WIN = 1
DEFENDER_WIN = 2
CONTINUE = 3
ROUND_OUT = 4
