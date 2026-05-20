## ADDED Requirements

### Requirement: Unified available coupon definition

The system SHALL define an **available coupon** as a user-held coupon record where `status = 0` (unused), `start_time <= current time`, and `end_time > current time`.

All user-facing counts and "my coupons" lists for available coupons MUST use this definition consistently across the member profile API, coupon list API, and payment coupon count API.

#### Scenario: Expired unused coupon excluded from available count

- **WHEN** a user holds a coupon with `status = 0` and `end_time` in the past
- **THEN** the member profile `couponCount` MUST be 0
- **AND** the `/coupon/my?type=0` list MUST NOT include that coupon

#### Scenario: Not-yet-started coupon excluded from available count

- **WHEN** a user holds a coupon with `status = 0` and `start_time` in the future
- **THEN** the member profile `couponCount` MUST be 0
- **AND** the `/coupon/my?type=0` list MUST NOT include that coupon

#### Scenario: Valid unused coupon included in available count

- **WHEN** a user holds a coupon with `status = 0`, `start_time <= now`, and `end_time > now`
- **THEN** the member profile `couponCount` MUST be 1
- **AND** the `/coupon/my?type=0` list MUST include that coupon

### Requirement: Receive rejects invalid coupons

The system MUST NOT allow a user to receive a coupon template whose validity period does not include the current time.

#### Scenario: Reject expired coupon template

- **WHEN** a user attempts to receive a coupon template with `end_time <= now`
- **THEN** the system MUST reject the request with a business error
- **AND** MUST NOT create a `yshop_coupon_user` record

#### Scenario: Reject not-yet-started coupon template

- **WHEN** a user attempts to receive a coupon template with `start_time > now`
- **THEN** the system MUST reject the request with a business error
- **AND** MUST NOT create a `yshop_coupon_user` record

#### Scenario: Allow receive of currently valid template

- **WHEN** a user attempts to receive a coupon template with `start_time <= now < end_time` and remaining inventory
- **THEN** the system MUST create a `yshop_coupon_user` record with `status = 0`

### Requirement: Unclaimed coupon list shows only receivable templates

The `/coupon/not` endpoint MUST return only coupon templates where `start_time <= now < end_time` and the user has not already received them.

#### Scenario: Expired template hidden from unclaimed list

- **WHEN** a coupon template has `end_time <= now`
- **THEN** the `/coupon/not` list MUST NOT include that template

#### Scenario: Future template hidden from unclaimed list

- **WHEN** a coupon template has `start_time > now`
- **THEN** the `/coupon/not` list MUST NOT include that template

### Requirement: User can view used and expired coupons

The mini-program coupon page MUST provide tabs for used coupons (`type=1`) and expired coupons (`type=2`) in addition to available and unclaimed coupons.

#### Scenario: Used coupon visible in used tab

- **WHEN** a user holds a coupon with `status = 1` within its original validity period
- **THEN** the "已使用" tab MUST display that coupon

#### Scenario: Expired coupon visible in expired tab

- **WHEN** a user holds a coupon with `end_time <= now`
- **THEN** the "已过期" tab MUST display that coupon

### Requirement: UI refreshes after receive

After a successful coupon receive or exchange, the mini-program MUST refresh the available coupon list and the member profile coupon count.

#### Scenario: Count updates after receive

- **WHEN** a user successfully receives a coupon
- **THEN** the home page `couponCount` MUST reflect the new available coupon on next page show
- **AND** the "我的优惠券" tab MUST show the newly received coupon
