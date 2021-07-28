extends Trigger

func is_on():
	return Game.currHpOrbs >= Game.maxHpOrbs
