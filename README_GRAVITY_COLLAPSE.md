Gravity Collapse Prototype

This README documents the prototype gravity-collapse feature added under `tools/gravity_collapse.lua` and the registry keys exposed in the mod.

What it does
- Samples underside points of dynamic bodies and estimates the supported fraction.
- If supported fraction falls below threshold for a short debounce period, applies a downward impulse to encourage collapse and tags the body (`gravity_collapsed`).

Files
- `tools/gravity_collapse.lua` - Prototype implementation. Exposes global hooks:
  - `gravity_collapse_init()`
  - `gravity_collapse_tick(dt)`
  - `gravity_collapse_update(dt)`
  - `gravity_collapse_draw()`

Registry keys (tunable in options menu -> IBSIT page)
- `savegame.mod.combined.ibsit_gravity_collapse` (bool) - enable/disable feature (existing key)
- `savegame.mod.combined.ibsit_collapse_threshold` (float) - collapse threshold used by IBSIT (existing key)
- `savegame.mod.combined.ibsit_gravity_force` (float) - gravity force multiplier used when triggering collapse (existing key)
- `savegame.mod.combined.gravitycollapse_sample_count` (int) - number of underside samples per body (default 24)
- `savegame.mod.combined.gravitycollapse_check_interval` (float) - seconds between checks (default 0.6)
- `savegame.mod.combined.gravitycollapse_min_mass` (int) - skip bodies smaller than this mass (default 50)
- `savegame.mod.combined.gravitycollapse_debug` (bool) - draw debug overlay (default false)
-- Additional advanced keys introduced in joint-aware prototype
- `savegame.mod.combined.gravitycollapse_joint_credit` (bool) - enable joint-graph crediting for support checks (default true)
- `savegame.mod.combined.gravitycollapse_joint_depth` (int) - BFS depth limit when traversing joint graph (default 6)
- `savegame.mod.combined.gravitycollapse_joint_mass_threshold` (int) - mass threshold used during joint traversal to consider a body "supportive" (default 100)
- `savegame.mod.combined.gravitycollapse_min_samples` (int) - minimum samples used by adaptive sampler (default 6)
- `savegame.mod.combined.gravitycollapse_max_samples` (int) - maximum samples used by adaptive sampler (default 64)

Caching & profiler

- `savegame.mod.combined.gravitycollapse_cache_grid` (float) - grid size (meters) used for raycast cache bucketing (default 0.25)
- `savegame.mod.combined.gravitycollapse_cache_ttl` (float) - time-to-live for cached raycasts in seconds (default 1.0)
- `savegame.mod.combined.gravitycollapse_cache_invalidate_on_check` (bool) - if true, rays around a body are invalidated when that body is checked (default false)
- `savegame.mod.combined.gravitycollapse_cache_invalidate_pad` (float) - padding when invalidating cache (default 0.05)
- `savegame.mod.combined.gravitycollapse_profiler` (bool) - show profiler overlay (default true)
- `savegame.mod.combined.gravitycollapse_profile_interval` (float) - profiler snapshot interval in seconds (default 1.0)

How to test

1. Open the mod in the Teardown editor or run the level with the mod enabled.

2. Open the Mod Options -> IBSIT v2.0 page and ensure "Gravity Collapse" is ON.

3. Toggle "Debug Overlay" to ON to show sampled support fractions in the world.

4. Create a simple test: a platform resting on tiny pegs (or a long beam touching at tiny points). Remove supports and observe whether the beam collapses when the supported fraction drops below the threshold.

5. Tune `Sample Count` and `Check Interval` to balance accuracy vs CPU.

Notes

- This is a prototype: it's intentionally conservative and safe. It applies impulses rather than aggressively breaking joints or editing shapes. If you want more destructive behavior (force detach joints, split shapes), I can extend the prototype, but it will require more careful testing.

- Cost: the sampling uses raycasts and is limited to a radius around the player. Increase `gravitycollapse_check_interval` or reduce `sample_count` to improve performance.

Adaptive sampling & joints

The prototype adapts the number of samples per-body based on the previous supported fraction; very stable bodies are sampled less. Tune `gravitycollapse_min_samples` and `gravitycollapse_max_samples` to control bounds.

When `gravitycollapse_joint_credit` is enabled the sampler will attempt to credit support if the hit body (or the evaluated body) is connected via joints to a static or large-mass body.

If you want: I can add a dedicated UI panel with advanced debugging options or implement joint-aware support crediting (count joints as partial support).
