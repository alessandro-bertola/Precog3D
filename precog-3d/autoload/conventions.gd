extends Node
## Naming and folder rules for PRECOG.
## Reusable content lives under characters/, components/, assets/.
## Level-specific content lives under levels/level_1/.
## Temporary placeholders use the tmp_ prefix and sit in assets/temp/.

const SCENE_BOOT := "res://ui/boot.tscn"
const SCENE_TEST := "res://levels/tests/test_sandbox.tscn"
const SCENE_LEVEL := "res://levels/level_1/level_1.tscn"

const AGENT_A := "AgentA"
const AGENT_B := "AgentB"
const CRIMINAL_1 := "Criminal1"
const CRIMINAL_2 := "Criminal2"
const CIVILIAN := "Civilian"

const GROUP_PAWNS := "pawns"
const GROUP_AGENTS := "agents"
const GROUP_CRIMINALS := "criminals"
const GROUP_CIVILIANS := "civilians"
const GROUP_DOORS := "doors"

const LAYER_WORLD := 1
const LAYER_CHARACTERS := 2
const LAYER_DOORS := 4
