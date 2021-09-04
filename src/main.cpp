#include <onnxruntime_cxx_api.h>

#include <opencv2/dnn/dnn.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#include "NumCpp.hpp"

#include <chrono>
#include <cmath>
#include <exception>
#include <fstream>
#include <iostream>
#include <limits>
#include <numeric>
#include <string>
#include <vector>

int main(int argc, char *argv[]) {
  
  auto a = nc::random::randInt<int>({10, 10}, 0, 100);

  // Initialize the ONNX Runtime.
  Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "test");
  Ort::SessionOptions session_options;

  // Load the model.
  std::cout << "Loading the model..." << std::endl;
  Ort::Session session(env, "/workspaces/scrfd_cpp/scrfd_10g_bnkps.onnx", session_options);

  size_t numInputNodes = session.GetInputCount();
  size_t numOutputNodes = session.GetOutputCount();

  std::cout << "Number of input nodes: " << numInputNodes << std::endl;
  std::cout << "Number of output nodes: " << numOutputNodes << std::endl;

  auto strides = {8, 16, 32};
  auto num_anchors = 2;

  // auto center_cache = std::vector<std::vector<float>>(num_anchors, std::vector<float>(num_anchors, 0.0));
  


  return 0;
}