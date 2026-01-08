#include "auraglow/engine.hpp"
#include <algorithm>
#include <cmath>

namespace auraglow {

static inline float clamp01(float v) { return std::max(0.0f, std::min(1.0f, v)); }
static inline uint8_t clampU8(int v) { return (uint8_t)std::max(0, std::min(255, v)); }

static inline float luminance(float r, float g, float b) {
  return 0.299f*r + 0.587f*g + 0.114f*b; // Rec.601
}

Status ApplyDyeRgb(FrameView frame, const MaskView& mask, const DyeParams& p) {
  if (!frame.data) return {false, "FrameView.data is null"};
  if (frame.width <= 0 || frame.height <= 0) return {false, "Invalid frame dimensions"};
  if (frame.stride <= 0) return {false, "Invalid frame stride"};
  if (!mask.data) return {false, "MaskView.data is null"};
  if (mask.width != frame.width || mask.height != frame.height) return {false, "Mask dimensions must match frame"};
  if (mask.stride <= 0) return {false, "Invalid mask stride"};

  const float intensity = clamp01(p.intensity);
  const float preserve  = clamp01(p.preserve_luma);

  const float dr = p.dye.r / 255.0f;
  const float dg = p.dye.g / 255.0f;
  const float db = p.dye.b / 255.0f;

  // Assumption: RGBA8 (4 bytes/pixel)
  for (int y = 0; y < frame.height; ++y) {
    uint8_t* row = frame.data + y * frame.stride;
    const uint8_t* mrow = mask.data + y * mask.stride;

    for (int x = 0; x < frame.width; ++x) {
      const int mi = mrow[x]; // 0..255
      if (mi == 0) { row += 4; continue; }

      const float wMask = (mi / 255.0f);
      const float w = intensity * wMask;

      float r = row[0] / 255.0f;
      float g = row[1] / 255.0f;
      float b = row[2] / 255.0f;

      const float baseLum = luminance(r,g,b);

      // Fast dye model: multiplicative + soft lift (stable in real-time)
      float dyedR = r * (0.5f + 0.5f*dr);
      float dyedG = g * (0.5f + 0.5f*dg);
      float dyedB = b * (0.5f + 0.5f*db);

      // Preserve luminance to avoid "helmet color"
      const float dyedLum = std::max(1e-6f, luminance(dyedR,dyedG,dyedB));
      const float lumScale = baseLum / dyedLum;

      float adjR = std::min(1.0f, dyedR * lumScale);
      float adjG = std::min(1.0f, dyedG * lumScale);
      float adjB = std::min(1.0f, dyedB * lumScale);

      // Blend raw dyed vs lum-preserved dyed
      float outR = dyedR*(1.0f-preserve) + adjR*preserve;
      float outG = dyedG*(1.0f-preserve) + adjG*preserve;
      float outB = dyedB*(1.0f-preserve) + adjB*preserve;

      // Final mix back to original
      r = r*(1.0f-w) + outR*w;
      g = g*(1.0f-w) + outG*w;
      b = b*(1.0f-w) + outB*w;

      row[0] = clampU8((int)std::lround(r * 255.0f));
      row[1] = clampU8((int)std::lround(g * 255.0f));
      row[2] = clampU8((int)std::lround(b * 255.0f));
      // alpha unchanged
      row += 4;
    }
  }

  return {true, "OK"};
}

} // namespace auraglow
