//
//  AnalyzerDrawing.metal
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 05.11.2023.
//

#include <metal_stdlib>
using namespace metal;

kernel void draw_metering(texture2d<float, access::write> output [[texture(0)]], uint2 gid [[thread_position_in_grid]], constant float *metering [[buffer(0)]], constant int &m_count [[buffer(1)]], constant int &buckets_count [[buffer(2)]]) {
    float4 color = float4(0.659, 0.859, 0.063, 1.0);
    float4 still_color = float4(0.0, 0.0, 0.0, 0.0);
    
    int pixels_in_bucket = output.get_width() / buckets_count;
    int bucket_position = floor((float(gid[0]) / output.get_width()) * float(buckets_count));
    
    float n_x_position_in_bucket = (float(gid[0]) - (float(pixels_in_bucket) * float(bucket_position))) / float(pixels_in_bucket);
    
    if (n_x_position_in_bucket < 0.33 || n_x_position_in_bucket > 0.67) {
        output.write(still_color, gid);
        return;
    }
    
    int m_units_by_bucket = m_count / buckets_count;
    
    int start_in_units = bucket_position * m_units_by_bucket;
    
    float avg = 0.0;
    int i;
    
    for (i = 0; i < m_units_by_bucket; i++) {
        avg += metering[start_in_units + i];
    }
    
    avg /= i;
    
    float n_position_in_drawable = float(gid[1]) / float(output.get_height());
    
    bool is_colored = (1.0 - n_position_in_drawable) < avg;
    
    output.write(is_colored ? color : still_color, gid);
}
