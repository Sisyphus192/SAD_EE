UndefineClass('Tame_crafting')
DefineClass.Tame_crafting = {
	__parents = { "Building", "OwnedComponent", "ProductionDeviceComponent" },
	__generated_by_class = "ModItemBuildingCompositeDef",


	object_class = "Building",
	LockState = "hidden",
	unload_anim_hands = "standing_DropDown_Hands",
	load_anim_hands = "standing_PickUp_Hands",
	BuildMenuCategory = "Devices",
	display_name = T(389785193957, --[[ModItemBuildingCompositeDef Tame_crafting display_name]] "Husbandry Station"),
	description = T(608043225179, --[[ModItemBuildingCompositeDef Tame_crafting description]] "Dedicated space for managing our herd."),
	BuildMenuIcon = "UI/Icons/Build Menu/chopping_block",
	BuildMenuPos = 1,
	display_name_pl = T(259002488281, --[[ModItemBuildingCompositeDef Tame_crafting display_name_pl]] "Husbandry Stations"),
	entity = "OutdoorCrafting",
	update_interval = 5000,
	construction_cost = PlaceObj('ConstructionCost', {
		Wood = 3000,
	}),
	construction_points = 2500,
	deconstruction_output = PlaceObj('ConstructionCost', {
		ScrapMetal = 10000,
	}),
	Health = 50000,
	MaxHealth = 50000,
	lock_block_box = box(-300, -300, 0, 300, 300, 600),
	SkirtSize = 239,
	EntityHeight = 580,
	CustomMaterial = "Wood",
	attack_attraction = 5,
	enable_overlay_on_placement = {
		RoomsOverlay = true,
	},
	OwnedComponent = true,
	ProductionDeviceComponent = true,
	interfaces = {
		"ee_tame",
	},
	override_material_during_production = false,
	ProductionDeviceSkipsStateChange = true,
}

