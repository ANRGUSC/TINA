import C5Checks
import Lean.Util.CollectAxioms
import Lean.Util.FoldConsts

/- Read-only metadata exporter; not imported by the proof module. -/
open Lean Elab Command
run_cmd do
  let env ← getEnv
  let mut rows : Array Json := #[]
  for (name, ci) in env.constants.toList do
    let some idx := env.getModuleIdxFor? name | continue
    let modName := env.header.moduleNames[idx.toNat]!
    if modName.toString != "C5Checks" then continue
    let deps := ci.getUsedConstantsAsSet.toArray.map (Json.str ∘ Name.toString)
    let ax ← collectAxioms name
    let ty ← liftTermElabM do return (← Meta.ppExpr ci.type).pretty
    let kind := match ci with
      | .thmInfo _ => "theorem"
      | .defnInfo _ => "definition"
      | .axiomInfo _ => "axiom"
      | .inductInfo _ => "inductive"
      | .ctorInfo _ => "constructor"
      | .recInfo _ => "recursor"
      | .opaqueInfo _ => "opaque"
      | .quotInfo _ => "quotient"
    rows := rows.push <| Json.mkObj [
      ("name", Json.str name.toString),
      ("module", Json.str modName.toString),
      ("kind", Json.str kind),
      ("type", Json.str ty),
      ("direct_constants", Json.arr deps),
      ("axioms", Json.arr (ax.map (Json.str ∘ Name.toString)))]
  liftIO <| IO.FS.writeFile "C5-dependencies.json" (Json.arr rows).pretty
