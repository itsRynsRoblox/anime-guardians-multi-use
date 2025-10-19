#Requires AutoHotkey v2.0

class CooldownManager {
    static cooldowns := Map()

    ; Sets a cooldown in milliseconds for the given action name
    static SetCooldown(name, durationMs) {
        this.cooldowns[name] := A_TickCount + durationMs
    }

    ; Returns true if the action is still on cooldown
    static IsOnCooldown(name) {
        return this.cooldowns.Has(name) && A_TickCount < this.cooldowns[name]
    }

    ; Returns remaining cooldown time in milliseconds (0 if ready)
    static GetRemaining(name) {
        if !this.cooldowns.Has(name)
            return 0
        remaining := this.cooldowns[name] - A_TickCount
        return remaining > 0 ? remaining : 0
    }

    ; Clears the cooldown
    static ClearCooldown(name) {
        this.cooldowns.Delete(name)
    }
}

ApplyCooldown(name, durationMs) {
    CooldownManager.SetCooldown(name, durationMs)
}

ClearCooldown(name) {
    CooldownManager.ClearCooldown(name)
}

IsOnCooldown(name) {
    return CooldownManager.IsOnCooldown(name)
}

SetChallengeCooldown() {
    CooldownManager.SetCooldown("Challenge", 30 * 60 * 1000) ; 30 minutes
}

IsChallengeOnCooldown() {
    return CooldownManager.IsOnCooldown("Challenge")
}

GetChallengeCooldownRemaining() {
    return Floor(CooldownManager.GetRemaining("Challenge") / 1000) ; seconds
}