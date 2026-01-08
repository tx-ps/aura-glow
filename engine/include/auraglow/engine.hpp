#pragma once
#include <cstdint>
#include <string>
#include <vector>

namespace auraglow {

struct Rgb8 { uint8_t r,g,b; };

struct FrameView {
  uint8_t* data = nullptr;
  int width = 0;
  int height = 0;
  int stride = 0; // bytes per row
};

struct DyeParams {
  Rgb8 dye{128, 32, 64};
  float intensity = 0.75f; // 0..1
  float preserve_luma = 0.9f; // 0..1
};

struct MaskView {
  const uint8_t* data = nullptr; // 0..255
  int width = 0;
  int height = 0;
  int stride = 0;
};

struct Status {
  bool ok = true;
  std::string message;
};

Status ApplyDyeRgb(FrameView frame, const MaskView& mask, const DyeParams& p);

} // namespace auraglow
