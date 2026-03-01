/*
 * SSDT-GPI0.dsl - Enable GPIO Controller for I2C ELAN1200 Precision Touchpad
 *
 * ASUS FX504GE-ES72 (Intel i7-8750H Coffee Lake)
 *
 * The ELAN1200 touchpad uses GPIO interrupt mode. macOS does not enable the
 * Intel GPIO controller (GPI0) by default on this platform, so VoodooI2C
 * cannot establish an interrupt and the touchpad stays unresponsive.
 *
 * This SSDT returns status 0x0F (present, enabled, functioning, show in UI)
 * for _SB.PCI0.GPI0 only when running under Darwin (macOS), leaving the
 * controller hidden from all other OSes.
 *
 * HOW TO USE:
 *   1. Compile this file with MaciASL or iasl:
 *        iasl -G SSDT-GPI0.dsl
 *      This produces SSDT-GPI0.aml in the same directory.
 *   2. Place SSDT-GPI0.aml in EFI/OC/ACPI/
 *   3. The entry in config.plist (ACPI > Add) is already present.
 *
 * DEPENDENCIES (all already configured in config.plist):
 *   - SSDT-XOSI.aml + _OSI -> XOSI ACPI patch  (Windows 10 simulation)
 *   - VoodooI2C.kext
 *   - VoodooI2CHID.kext
 *   - VoodooInput.kext (plugin inside VoodooI2C, now enabled)
 *   - VoodooPS2Trackpad.kext must be DISABLED (now disabled) to avoid conflict
 */

DefinitionBlock ("", "SSDT", 2, "HACK", "GPI0FIX", 0x00000000)
{
    External (_SB_.PCI0.GPI0, DeviceObj)

    Scope (_SB.PCI0.GPI0)
    {
        /*
         * _STA: return 0x0F only under Darwin so the GPIO controller is
         * visible to VoodooI2C. Under all other operating systems the
         * hardware firmware value is preserved (Zero = hidden).
         */
        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0F)
            }
            Else
            {
                Return (Zero)
            }
        }
    }
}
