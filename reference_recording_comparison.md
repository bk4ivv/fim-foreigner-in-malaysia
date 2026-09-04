# Reference app versus FIM — design comparison

## Observed in the supplied recording

The reference app uses a hub-and-spoke product structure with a branded splash screen, a broad 3-column home grid, an announcement/ad area, an urgent-update strip, and persistent bottom navigation. Its secondary pages use standardized white cards, large colorful illustrative icons, trailing chevrons, searchable/tabbed modules, news thumbnails, timestamps, and custom empty states. The recording shows visible feedback for loading and modal language selection.

## Current FIM implementation

FIM is intentionally narrower and utility-first. Its dashboard exposes a Malaysian-service hero, a verified-alert strip, a compact 3-column service grid, a separate Tools entry, and a country-support entry when relevant. The primary shell currently has three destinations rather than the recording’s broader four-area structure. FIM uses official service marks and a graphite/cobalt/Malaysian-flag visual system, with subtle batik and Malaysian cultural motion added in v2.14.0.

## Why the reference feels better

The largest difference is not Flutter versus JavaScript or Python. It is **perceived product depth**. The reference fills the dashboard with more recognizable destinations, media, status cues, and community surfaces, so it feels like a complete service ecosystem. FIM’s core surfaces are cleaner but sparser; users see fewer large visual anchors and fewer immediately visible content states.

The reference also has stronger component repetition: colorful icon tiles, white cards, chevrons, timestamps, thumbnails, tabs, and empty-state illustrations recur across modules. That creates a fast visual grammar. FIM has more restraint and stronger official-service credibility, but its mix of hero panels, compact tiles, logos, text-heavy list tiles, and secondary routes can feel less uniform.

The reference’s Bengali typography and localized labels appear to be treated as a first-class visual system. In FIM, the source still contains some English system labels and mixed-language utility copy in otherwise localized flows. That weakens the sense of a fully native Bangla experience, even when the feature set is present.

The reference makes interaction feedback highly visible: splash progress, bottom-sheet/modal motion, card navigation affordances, data spinners, and illustrated empty states. FIM’s v2.14 motion is deliberately subtle and mostly shell-level. It improves atmosphere, but it does not yet provide the same amount of **task-specific feedback** at the moment users tap, search, load, or encounter no results.

## Safe redesign direction

Do not copy the reference branding or proprietary UI. Borrow the proven patterns: a stronger home information hierarchy, larger expressive service tiles, more consistent card grammar, visible loading and empty states, a richer localized Bengali typography pass, and more purposeful micro-interactions. Keep FIM’s advantages: official links, in-app web viewing, country-first onboarding, offline learning data, readable dark mode, and Malaysian cultural identity.
