import LCSS
import Lean.Util.CollectAxioms
import Lean.Util.FoldConsts

open Lean Elab Command

#print axioms LCSS.theorem1
#check @LCSS.theorem1
#print axioms LCSS.theorem2
#check @LCSS.theorem2
#print LCSS.Parameters
#print LCSS.PaperComponents
#print LCSS.RefreshTrace
#print LCSS.RefreshControls
#print LCSS.RefreshStrategy
#print LCSS.Theorem2Claims
#print LCSS.PaperModel
#print LCSS.Theorem1Claims
#print axioms LCSS.theorem1_arithmetic
#check @LCSS.theorem1_arithmetic
#print axioms LCSS.theorem2_time_integrated_lower_bounds
#check @LCSS.theorem2_time_integrated_lower_bounds
#print axioms LCSS.FiniteGaussianWitness.finite_ou_witness
#check @LCSS.FiniteGaussianWitness.finite_ou_witness
#print LCSS.PhysicalSchedule
#print LCSS.AgentCoordinates
#print LCSS.ScheduledPolicy
#print LCSS.ScheduledStrategy
#print LCSS.MeasuredRefreshControls
#print LCSS.MeasuredRefreshStrategy
#print LCSS.ScheduledStrategy.timeAverage
#print axioms LCSS.theorem2_physical_attainment
#check @LCSS.theorem2_physical_attainment
#print LCSS.CanonicalLossRegularity
#check @LCSS.CanonicalLossRegularity.of_measurable_coordinates
#print LCSS.ScheduledPolicy.canonicalAction
#check @LCSS.ScheduledPolicy.canonical_controls_cost
#check @LCSS.ScheduledStrategy.canonical_average
#check @LCSS.ScheduledStrategy.noRefresh_cost
#check @LCSS.ScheduledStrategy.periodic_cost

#print axioms LCSS.theorem2_raw_physical_attainment
#check @LCSS.theorem2_raw_physical_attainment
#print LCSS.RawRealization
#print LCSS.RawScheduledPolicy
set_option pp.explicit true in
#check @LCSS.RawScheduledPolicy.feasible
#print LCSS.RawScheduledStrategy
#print LCSS.RawScheduledStrategy.timeAverage
#check @LCSS.RawRealization.receivedInfo_informationSpace
#check @LCSS.informationSpace_iSup_comap_congr
#check @LCSS.RawRealization.expected_integrated_raw_loss
#check @LCSS.RawScheduledStrategy.expected_horizon_cost

#print axioms LCSS.theorem2_inclusive_lower_bounds
#check @LCSS.theorem2_inclusive_lower_bounds
#print axioms LCSS.theorem2_inclusive_physical_attainment
#check @LCSS.theorem2_inclusive_physical_attainment
#print axioms LCSS.InclusiveRawStrategy.expected_horizon_lower_bound
#check @LCSS.InclusiveRawStrategy.expected_horizon_lower_bound
#print LCSS.PhysicalSchedule.receivedBy
#print LCSS.PhysicalSchedule.receptionTimes
#print LCSS.InclusiveRawPolicy
set_option pp.explicit true in
#check @LCSS.InclusiveRawPolicy.feasible
#print LCSS.InclusiveRawStrategy
#print LCSS.InclusiveRawStrategy.timeAverage
#check @LCSS.InclusiveRawPolicy.toStrict_loss_phase_ae
#check @LCSS.InclusiveRawPolicy.toStrict_integrated_loss
#check @LCSS.InclusiveRawStrategy.toStrict_timeAverage
#check @LCSS.InclusiveRawStrategy.toStrict_timeUpperCost
#check @LCSS.RawScheduledPolicy.toInclusive

#print axioms LCSS.full_model_witness
#check @LCSS.full_model_witness
#print axioms LCSS.theorem1_ou
#check @LCSS.theorem1_ou
#print axioms LCSS.theorem2_ou_physical_attainment
#check @LCSS.theorem2_ou_physical_attainment
#print LCSS.IndependentOU.realization
#print LCSS.IndependentOU.components

/-! This command only inspects already elaborated constants. It does not
participate in any mathematical proof or introduce declarations into LCSS. -/
run_cmd do
  let env ← getEnv
  let mut rows : Array Json := #[]
  let mut vendorRows : Array Json := #[]
  for (name, ci) in env.constants.toList do
    let some idx := env.getModuleIdxFor? name | continue
    let modName := env.header.moduleNames[idx.toNat]!
    let isLocal := modName.toString.startsWith "LCSS"
    let isVendor := modName.toString.startsWith "BrownianMotion." ||
      modName.toString.startsWith "KolmogorovExtension4."
    if !isLocal && !isVendor then continue
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
    let row := Json.mkObj [
      ("name", Json.str name.toString),
      ("module", Json.str modName.toString),
      ("kind", Json.str kind),
      ("type", Json.str ty),
      ("direct_constants", Json.arr deps),
      ("axioms", Json.arr (ax.map (Json.str ∘ Name.toString)))]
    if isLocal then rows := rows.push row else vendorRows := vendorRows.push row
  liftIO <| IO.FS.writeFile "evidence/vendor-dependencies.json" (Json.arr vendorRows).pretty
  liftIO <| IO.FS.writeFile "evidence/lean-dependencies.json" (Json.arr rows).pretty
