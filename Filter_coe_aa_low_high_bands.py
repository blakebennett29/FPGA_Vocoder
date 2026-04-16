import os
import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# User settings
# ============================================================
NUM_TAPS = 127
WINDOW = "hamming"   # "hamming", "hann", "blackman", "rect"
RADIX = 10          # 10 or 16
OUT_DIR = r"E:\School\SeniorProject\simple_FIR_coe_python\generated_coe"

# ============================================================
# Sample-rate tree
# ============================================================
FS_IN = 192_000.0    # starting sample rate
FS_L1 = 96_000.0     # after first /2
FS_L2 = 48_000.0     # after second /2

# ============================================================
# Cutoff frequencies
# ============================================================
FC_AA_48K = 48_000.0   # AA before 192k -> 96k
FC_AA_24K = 24_000.0   # AA before 96k -> 48k
FC_SPLIT  = 12_000.0   # low/high split at fs = 48k (Nyquist = 24k)

# ============================================================
# Q1.23 constants
# ============================================================
Q_FRAC_BITS = 23
Q_SCALE = 2 ** Q_FRAC_BITS
Q1_23_MIN_INT = -(2 ** 23)
Q1_23_MAX_INT = (2 ** 23) - 1
Q1_23_MIN_FLOAT = -1.0
Q1_23_MAX_FLOAT = Q1_23_MAX_INT / Q_SCALE

# ============================================================
# FIR helper functions
# ============================================================
def window_fn(name: str, n: int) -> np.ndarray:
    name = name.lower()
    if name == "hamming":
        return np.hamming(n)
    if name == "hann":
        return np.hanning(n)
    if name == "blackman":
        return np.blackman(n)
    if name == "rect":
        return np.ones(n)
    raise ValueError(f"Unknown window: {name}")

def design_lowpass_fir(
    fs: float,
    fc: float,
    num_taps: int,
    window: str = "hamming",
    gain: float = 1.0
) -> np.ndarray:
    if not (0 < fc < fs / 2):
        raise ValueError(f"Cutoff must be between 0 and Nyquist. Got fc={fc}, fs={fs}")
    if num_taps < 2:
        raise ValueError("num_taps must be >= 2")

    n = np.arange(num_taps)
    m = (num_taps - 1) / 2.0
    fc_norm = fc / fs

    h_ideal = 2.0 * fc_norm * np.sinc(2.0 * fc_norm * (n - m))
    h = h_ideal * window_fn(window, num_taps)

    # Normalize DC gain to 1, then apply requested gain
    h /= np.sum(h)
    h *= gain

    return h

def spectral_shift_neg1n(h: np.ndarray) -> np.ndarray:
    n = np.arange(len(h))
    return h * ((-1) ** n)

def freq_response(h: np.ndarray, fs: float, nfft: int = 16384):
    H = np.fft.rfft(h, n=nfft)
    f = np.fft.rfftfreq(nfft, d=1.0 / fs)
    return f, H

# ============================================================
# Q1.23 safety helpers
# ============================================================
def report_q1_23_headroom(name: str, h: np.ndarray):
    peak_pos = np.max(h)
    peak_neg = np.min(h)
    peak_abs = np.max(np.abs(h))
    clips = (peak_pos > Q1_23_MAX_FLOAT) or (peak_neg < Q1_23_MIN_FLOAT)

    print(f"\n{name}")
    print(f"  float max coeff : {peak_pos:.12f}")
    print(f"  float min coeff : {peak_neg:.12f}")
    print(f"  float max abs   : {peak_abs:.12f}")
    print(f"  Q1.23 max       : {Q1_23_MAX_FLOAT:.12f}")
    print(f"  Q1.23 min       : {Q1_23_MIN_FLOAT:.12f}")
    print(f"  clips before scaling? {'YES' if clips else 'NO'}")

def scale_to_q1_23_safe(h: np.ndarray):
    peak_abs = np.max(np.abs(h))

    if peak_abs == 0:
        return h.copy(), 1.0

    if peak_abs > Q1_23_MAX_FLOAT:
        scale = Q1_23_MAX_FLOAT / peak_abs
        return h * scale, scale

    return h.copy(), 1.0

# ============================================================
# Quantization / .coe writing
# ============================================================
def quantize_q1_23(h: np.ndarray) -> np.ndarray:
    q = np.round(h * Q_SCALE).astype(np.int64)
    q = np.clip(q, Q1_23_MIN_INT, Q1_23_MAX_INT).astype(np.int64)
    return q

def int_to_twos_hex(v: int, bits: int = 24) -> str:
    if v < 0:
        v = (1 << bits) + v
    return f"{v:0{bits // 4}X}"

def write_coe(coeff_q: np.ndarray, path: str, radix: int = 16):
    """
    Writes .coe in the format:

    radix = 16;
    coefdata =
    000123,
    FFFABC,
    ...
    7FFFFF;
    """
    if radix not in (10, 16):
        raise ValueError("RADIX must be 10 or 16")

    lines = []
    lines.append(f"radix = {radix};")
    lines.append("coefdata =")

    for i, v in enumerate(coeff_q):
        if radix == 10:
            s = str(int(v))
        else:
            s = int_to_twos_hex(int(v), bits=24)

        end = "," if i != len(coeff_q) - 1 else ";"
        lines.append(f"{s}{end}")

    with open(path, "w", newline="\n") as f:
        f.write("\n".join(lines))

# ============================================================
# Plot + save helper
# ============================================================
def save_filter(name: str, h: np.ndarray, fs: float, fc_marker: float):
    os.makedirs(OUT_DIR, exist_ok=True)

    report_q1_23_headroom(name, h)

    h_safe, applied_scale = scale_to_q1_23_safe(h)

    if applied_scale != 1.0:
        print(f"  applied safety scale: {applied_scale:.12f}")
    else:
        print("  applied safety scale: none")

    peak_pos_safe = np.max(h_safe)
    peak_neg_safe = np.min(h_safe)
    clips_after = (peak_pos_safe > Q1_23_MAX_FLOAT) or (peak_neg_safe < Q1_23_MIN_FLOAT)
    print(f"  clips after scaling? {'YES' if clips_after else 'NO'}")

    h_q = quantize_q1_23(h_safe)
    h_q_float = h_q.astype(np.float64) / Q_SCALE

    sat_pos = np.sum(h_q == Q1_23_MAX_INT)
    sat_neg = np.sum(h_q == Q1_23_MIN_INT)
    print(f"  quantized +fullscale count: {sat_pos}")
    print(f"  quantized -fullscale count: {sat_neg}")

    coe_path = os.path.join(OUT_DIR, f"{name}.coe")
    write_coe(h_q, coe_path, radix=RADIX)
    print(f"  wrote: {coe_path}")

    plt.figure(figsize=(10, 4))
    plt.title(f"{name} coefficients")
    plt.stem(h_safe, basefmt=" ", markerfmt=" ", linefmt="-", label="float (safe)")
    plt.stem(h_q_float, basefmt=" ", markerfmt=" ", linefmt="--", label="Q1.23")
    plt.xlabel("Tap n")
    plt.ylabel("h[n]")
    plt.grid(True)
    plt.legend()

    f, H = freq_response(h_safe, fs)
    f2, H2 = freq_response(h_q_float, fs)

    mag_db = 20 * np.log10(np.maximum(np.abs(H), 1e-12))
    mag_db_q = 20 * np.log10(np.maximum(np.abs(H2), 1e-12))

    plt.figure(figsize=(10, 5))
    plt.title(f"{name} response")
    plt.plot(f, mag_db, label="float (safe)")
    plt.plot(f2, mag_db_q, "--", label="Q1.23")
    plt.axvline(fc_marker, linestyle="--", label=f"cutoff = {fc_marker/1000:.1f} kHz")
    plt.xlim(0, fs / 2)
    plt.ylim(-140, 10)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True)
    plt.legend()

# ============================================================
# Main
# ============================================================
def main():
    # 1) AA filter for 192k -> 96k
    aa_48k_g1 = design_lowpass_fir(
        fs=FS_IN,
        fc=FC_AA_48K,
        num_taps=NUM_TAPS,
        window=WINDOW,
        gain=1.0
    )
    aa_48k_g2 = design_lowpass_fir(
        fs=FS_IN,
        fc=FC_AA_48K,
        num_taps=NUM_TAPS,
        window=WINDOW,
        gain=2.0
    )

    save_filter("AA_ds_192_to_96_fc48k_g1_q1_23", aa_48k_g1, FS_IN, FC_AA_48K)
    save_filter("AA_ds_192_to_96_fc48k_g2_q1_23", aa_48k_g2, FS_IN, FC_AA_48K)

    # 2) AA filter for 96k -> 48k
    aa_24k_g1 = design_lowpass_fir(
        fs=FS_L1,
        fc=FC_AA_24K,
        num_taps=NUM_TAPS,
        window=WINDOW,
        gain=1.0
    )
    aa_24k_g2 = design_lowpass_fir(
        fs=FS_L1,
        fc=FC_AA_24K,
        num_taps=NUM_TAPS,
        window=WINDOW,
        gain=2.0
    )

    save_filter("AA_ds_96_to_48_fc24k_g1_q1_23", aa_24k_g1, FS_L1, FC_AA_24K)
    save_filter("AA_ds_96_to_48_fc24k_g2_q1_23", aa_24k_g2, FS_L1, FC_AA_24K)

    # 3) Split filters at fs = 48k, split at 12k
    lp_12k_g1 = design_lowpass_fir(
        fs=FS_L2,
        fc=FC_SPLIT,
        num_taps=NUM_TAPS,
        window=WINDOW,
        gain=1.0
    )
    lp_12k_g2 = design_lowpass_fir(
        fs=FS_L2,
        fc=FC_SPLIT,
        num_taps=NUM_TAPS,
        window=WINDOW,
        gain=2.0
    )

    hp_12k_g1 = spectral_shift_neg1n(lp_12k_g1)
    hp_12k_g2 = spectral_shift_neg1n(lp_12k_g2)

    save_filter("LP_split_fs48k_fc12k_g1_q1_23", lp_12k_g1, FS_L2, FC_SPLIT)
    save_filter("LP_split_fs48k_fc12k_g2_q1_23", lp_12k_g2, FS_L2, FC_SPLIT)

    save_filter("HP_split_fs48k_fc12k_neg1n_g1_q1_23", hp_12k_g1, FS_L2, FC_SPLIT)
    save_filter("HP_split_fs48k_fc12k_neg1n_g2_q1_23", hp_12k_g2, FS_L2, FC_SPLIT)

    print("\nDone.")
    plt.show()

if __name__ == "__main__":
    main()