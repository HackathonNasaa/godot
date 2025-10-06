extends Control


@onready var budget_label: Label = $CanvasLayer/BudgetContainer/BudgetLabel

func _ready():
	GameState.budget_changed.connect(_on_budget_changed)
	_on_budget_changed(GameState.budget)

func _on_budget_changed(new_budget: int):
	if budget_label:
		budget_label.text = "$%s" % new_budget
