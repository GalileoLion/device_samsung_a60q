# Samsung Galaxy A60 Device Tree

Device tree bring-up for Samsung Galaxy A60 (`a60q`, SM-A6060).

This tree is intended to inherit from `device/samsung/sm6150-common` and use the SM6150 A70 ecosystem only where the hardware is shared and verified.

Current status:

- LineageOS target branch direction: `lineage-22.2`
- Stock firmware source analyzed first: TGY `A6060ZHU3CXE1`
- Board name verified from stock boot/recovery: `RILRL28A003`
- Non-dynamic partition layout verified from A60 PIT
- Initial A60 recovery/vendor fstab added
- Initial A60-specific proprietary blob list added
- TGY source dump prepared locally for extract-utils
- A60 vendor blobs have been extracted successfully in the lightweight workspace
- SM6150 common vendor blobs extract successfully after applying the A60 common proprietary-list patch in `patches/`
- Full Lineage build validation has not been run yet

See `PLAN.md` for the bring-up plan and known risk areas.
