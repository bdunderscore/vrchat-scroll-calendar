#define SCROLLCAL_DSOFF_DATASTREAM_WIDTH 0 // 250
#define SCROLLCAL_DSOFF_DATASTREAM_HEIGHT 1 // 1344
#define SCROLLCAL_DSOFF_VIEWPORT_W 2 // 1024
#define SCROLLCAL_DSOFF_VIEWPORT_H 3 // 1447
#define SCROLLCAL_DSOFF_HEADER_H 4 // 624
#define SCROLLCAL_DSOFF_FOOTER_H 5 // 121
#define SCROLLCAL_DSOFF_BORDER_L 6 // 35
#define SCROLLCAL_DSOFF_BORDER_R 7 // 35
#define SCROLLCAL_DSOFF_DAY_HEADER_HEIGHT 8 // 95
#define SCROLLCAL_DSOFF_DIV 9 // 148
#define SCROLLCAL_DSOFF_PALETTE 12
#define SCROLLCAL_DSOFF_SECTION_PAD 20 // 8
#define SCROLLCAL_DSOFF_SCROLL_HEIGHT 21 // 3152
#define SCROLLCAL_DSOFF_SCROLL_TEX_Y 22 // 944
#define SCROLLCAL_DSOFF_BG_SAMPLE_Y 23 // 896
#define SCROLLCAL_DSOFF_BG_SAMPLE_H 24 // 32
#define SCROLLCAL_DSOFF_HEADER_TEX_Y 25 // 111
#define SCROLLCAL_DSOFF_FOOTER_TEX_Y 26 // 759
#define SCROLLCAL_DSOFF_DAY_HEADER_TEX_X 27 // 718
#define SCROLLCAL_DSOFF_DAY_HEADER_TEX_ALPHA_X 28 // 750
#define SCROLLCAL_DSOFF_DAY_HEADER_TEX_Y 29 // 0
#define SCROLLCAL_DSOFF_DAY_HEADER_SIDE_WIDTH 30 // 8
#define SCROLLCAL_DSOFF_DAY_HEADER_TRUE_WIDTH 31 // 954
#define SCROLLCAL_DSOFF_HEADER_BLEND_START 32 // 16
#define SCROLLCAL_DSOFF_HEADER_BLEND_END 33 // 32
#define SCROLLCAL_DSOFF_SCROLL_SPLIT_POINT 34 // 1326
#define SCROLLCAL_DSOFF_VDATA_LEN 35 // 9456
#define SCROLLCAL_DSOFF_PREVDH 36

#define SCROLLCAL_IS_DAY_HEADER (1 << 17)

#define SCROLLCAL_SAMPLER_POINT scrollcal_sampler_point_clamp
#define SCROLLCAL_SAMPLER_TEX scrollcal_sampler_trilinear_clamp

#define SCROLLCAL_DAY_HEADER_BLEND 3

Texture2D _MainTex;
SamplerState SCROLLCAL_SAMPLER_POINT;
SamplerState SCROLLCAL_SAMPLER_TEX;
float4 _MainTex_TexelSize;
float4 _MainTex_ST;

int scrollcal_decode_rgb(fixed3 col) {
    float3 gamma = LinearToGammaSpace(col);
    int3 nibbles = round(gamma * 63.0);

    return dot(int3(1 << 12, 1 << 6, 1), nibbles);
}

float2 scrollcal_px_to_uv(int2 px) {
    float2 px_f = px;
    px_f += float2(0.5, 0.5);
    px_f *= _MainTex_TexelSize.xy;

    return px_f;
}

float2 scrollcal_index_to_uv(uint data_width, uint offset) {
    uint row = offset / data_width;
    uint col = offset % data_width;

    int x = (int)_MainTex_TexelSize.z - 1 - col;
    int y = (int)_MainTex_TexelSize.w - 1 - row;

    return scrollcal_px_to_uv(int2(x,y));
}

fixed4 scrollcal_load_rgb(int data_width, int index) {
    return _MainTex.SampleLevel(SCROLLCAL_SAMPLER_POINT, scrollcal_index_to_uv(data_width, index), 0);
}

int scrollcal_load_int(int data_width, int index) {
    return scrollcal_decode_rgb(scrollcal_load_rgb(data_width, index));
}

int scrollcal_load_data_width() {
    return scrollcal_decode_rgb(_MainTex.SampleLevel(
        SCROLLCAL_SAMPLER_POINT,
        float2(1.0, 1.0) - (float2(0.5, 0.5) * _MainTex_TexelSize.xy),
        0
    ));
}

#define SCROLLCAL_CTX_V2F \
    float4 sc_p1 : TEXCOORD10; \
    float4 sc_p2 : TEXCOORD11; \
    float4 sc_p3 : TEXCOORD12; \
    float4 sc_p4 : TEXCOORD13; \
    float4 sc_p5 : TEXCOORD14; \
    float4 sc_p6 : TEXCOORD15; \
    float4 sc_p7 : TEXCOORD16; \
    float4 sc_p8 : TEXCOORD17;

#define SCROLLCAL_CTX_FROM_V2F(ctx, v2f) \
    struct scrollcal_context ctx; \
    ctx.viewport_size = float4(v2f.sc_p1.xy, round(v2f.sc_p1.zw)); \
    ctx.borders = round(v2f.sc_p2); \
    ctx.scroll_tex_params = round(v2f.sc_p3); \
    ctx.data_width = round(v2f.sc_p3.w); \
    ctx.other_tex_params = round(v2f.sc_p4); \
    ctx.day_header_params = round(v2f.sc_p5); \
    ctx.border_tex_params = round(v2f.sc_p6); \
    ctx.column_offsets = round(v2f.sc_p7); \
    ctx.split_params = float4(round(v2f.sc_p8.xyz), v2f.sc_p8.w)

#define SCROLLCAL_CTX_TO_V2F(v2f, uv) \
    do { \
        struct scrollcal_context ctx = scrollcal_bootstrap(uv); \
        v2f.sc_p1 = ctx.viewport_size; \
        v2f.sc_p2 = ctx.borders; \
        v2f.sc_p3 = ctx.scroll_tex_params; \
        v2f.sc_p4 = ctx.other_tex_params; \
        v2f.sc_p5 = ctx.day_header_params; \
        v2f.sc_p6 = ctx.border_tex_params; \
        v2f.sc_p7 = ctx.column_offsets; \
        v2f.sc_p8 = ctx.split_params; \
    } while(0)

struct scrollcal_context {
    int data_width;
    float4 viewport_size; // x, y, w, h
    float4 borders; // HEADER_H FOOTER_H BORDER_L BORDER_R

    // offset, tex_y, height, data_width 
    // Note: When encoded, we stick data_width here instead
    float4 scroll_tex_params;

    // bg_sample_y, bg_sample_h, day_header_side_width, vdata_len
    float4 other_tex_params;

    // dh_height, tex_x, tex_alpha_x, tex_y
    float4 day_header_params;
    
    // header_tex_y, footer_tex_y, section_pad, prev_day_header
    float4 border_tex_params;

    // col1 col2 col3
    float4 column_offsets;

    // x - blend start
    // y - blend end
    // z - side split offset (view Y coordinates)
    // w - header shift distance
    float4 split_params;
};

struct scrollcal_context scrollcal_bootstrap(float2 uv) {
    struct scrollcal_context ctx;

    ctx.data_width = scrollcal_load_data_width();
    ctx.viewport_size.z = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_VIEWPORT_W);
    ctx.viewport_size.w = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_VIEWPORT_H);
    ctx.viewport_size.xy = float2(uv.x, 1 - uv.y) * ctx.viewport_size.zw;

    ctx.borders = float4(
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_HEADER_H),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_FOOTER_H),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_BORDER_L),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_BORDER_R)
    );

    ctx.scroll_tex_params.y = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_SCROLL_TEX_Y);
    ctx.scroll_tex_params.z = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_SCROLL_HEIGHT);
    ctx.scroll_tex_params.z *= 3;
    ctx.scroll_tex_params.w = ctx.data_width;

    float scroll_play = max(0, ctx.scroll_tex_params.z - (ctx.viewport_size.w - ctx.borders.x - ctx.borders.y));

    // Subtract the scrollable portion of the top header to avoid ugly blank space at the end. However, we do need
    // to preserve enough space to scroll past the top header.

    ctx.scroll_tex_params.x = scroll_play * _Position;

    ctx.other_tex_params = float4(
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_BG_SAMPLE_Y),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_BG_SAMPLE_H),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DAY_HEADER_SIDE_WIDTH),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_VDATA_LEN)
    );

    ctx.day_header_params = float4(
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DAY_HEADER_HEIGHT),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DAY_HEADER_TEX_X),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DAY_HEADER_TEX_ALPHA_X),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DAY_HEADER_TEX_Y)
    );

    ctx.border_tex_params = float4(
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_HEADER_TEX_Y),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_FOOTER_TEX_Y),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_SECTION_PAD),
        0 // will fill in later
    );

    ctx.column_offsets = float4(
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DIV + 0),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DIV + 1),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_DIV + 2),
        0
    );
    
    // Perform view split adjustment
    // TODO: un-hardcode
    float header_blend_start = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_HEADER_BLEND_START);
    float header_blend_end = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_HEADER_BLEND_END);
    float max_scale_up = ctx.borders.x - header_blend_end;

    float header_shift = min(max_scale_up, ctx.scroll_tex_params.x);

    ctx.split_params = float4(
        header_blend_start,
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_HEADER_BLEND_END),
        scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_SCROLL_SPLIT_POINT),
        header_shift
    );

    ctx.borders.x -= header_shift;
    ctx.scroll_tex_params.x = max(0, ctx.scroll_tex_params.x -= header_shift);

    ctx.border_tex_params.w = scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_PREVDH + max(0, floor(ctx.scroll_tex_params.x)));

    return ctx;
}

float2 scrollcal_px_to_uv(struct scrollcal_context ctx, float2 px) {
    return float2(px.x * _MainTex_TexelSize.x, 1.0 - (px.y * _MainTex_TexelSize.y));
}

/*
 *
 * Layers:
 *
 *  - texture(background_uv)
 *  - TEXT: color; alpha: dot(texture(text_uv), colormask)
 *  - overlay: alpha: texture(alpha_uv), albedo: texture(overlay_uv)
 *
 * Flag: overlay_above_of_text

 *
 * Modes:
 *   Top header border: (0..DAY_HEADER_SIDE_WIDTH)
 *     background only (pulling from header section)
 *   Top header body:
 *     background: day header sampler
 *     text: main text area
 *     overlay none
 *   Interior header top border, overlapping top header:
 *     background: header section (if top header is zero) or day header sampler (otherwise)
 *     text: unused
 *     overlay: day header sampler
 *       overlay_above_text (except within SIDE_WIDTH of sides)
 *   Interior header body and bottom border:
 *     background: body background sampler
 *     overlay: day header sampler
 *     text: main text area
 *   Body:
 *     background: body background sampler
 *     overlay: none
 *     text: main text area
 */

struct scrollcal_render_plan {
// UV coordinate space
    float2 background_uv;
    float2 overlay_uv; // if -1, -1, ignore
    float2 overlay_alpha_uv; // if -1, -1, ignore
    float2 text_uv;
    
    // This is dotted into the texture at text_uv to compute an alpha value
    fixed4 colormask;

    float2 palette_uv;
    bool overlay_above_text;

    float overlay_alpha_mul;
};

struct scrollcal_render_plan scrollcal_plan_fixed(struct scrollcal_context ctx, float2 px) {
    struct scrollcal_render_plan plan;
    plan.background_uv = scrollcal_px_to_uv(ctx, px);
    plan.overlay_uv = float2(-1, -1);
    plan.overlay_alpha_uv = float2(-1, -1);
    plan.text_uv = float2(-1, -1);
    plan.colormask = fixed4(0,0,0,0);
    plan.palette_uv = float2(-1, -1);
    plan.overlay_above_text = false;
    plan.overlay_alpha_mul = 0;

    return plan;
}


struct scrollcal_render_plan scrollcal_plan_header(struct scrollcal_context ctx, float2 uv_px) {
    float y_base = ctx.border_tex_params.x;
    float y_scroll = y_base + ctx.split_params.w;

    struct scrollcal_render_plan plan;

    plan.background_uv = scrollcal_px_to_uv(ctx, uv_px + float2(0, y_scroll));
    plan.overlay_uv = float2(-1, -1);
    plan.overlay_alpha_uv = float2(-1, -1);
    plan.text_uv = float2(-1, -1);
    plan.colormask = fixed4(0,0,0,0);
    plan.palette_uv = float2(-1, -1);
    plan.overlay_above_text = false;

    if (uv_px.y < ctx.split_params.y) {
        plan.overlay_alpha_mul = 1 - smoothstep(ctx.split_params.x, ctx.split_params.y, uv_px.y);
        plan.overlay_uv = scrollcal_px_to_uv(ctx, uv_px + float2(0, y_base));
    }

    return plan;
}

struct scrollcal_render_plan scrollcal_plan_footer(struct scrollcal_context ctx, float2 uv_px) {
    uv_px.y -= (ctx.viewport_size.w - ctx.borders.y);
    uv_px.y += ctx.border_tex_params.y;

    return scrollcal_plan_fixed(ctx, uv_px);
}


struct scrollcal_render_plan scrollcal_plan_side(struct scrollcal_context ctx, float2 uv_px, int index) {
    float pad = ctx.border_tex_params.z;
    
    uv_px.x += pad;

    // Correct for header scroll. We divide into three regions:
    // uv_px.y + shift <= split point => render locked to header
    // uv_px.y > ctx.split_params.z: Lock to booter
    // Anywhere else: Lock to split point coordinate
    if (uv_px.y + ctx.split_params.w <= ctx.split_params.z) {
        uv_px.y -= ctx.borders.x; // subtract header height
    } else if (uv_px.y > ctx.split_params.z) {
        uv_px.y -= (ctx.borders.x + ctx.split_params.w);
    } else {
        uv_px.y = ctx.split_params.z - (ctx.borders.x + ctx.split_params.w);
    }
    
    if (index > 0) {
        uv_px.x += ctx.borders.z;
        uv_px.x += pad * 2;
    }

    return scrollcal_plan_fixed(ctx, uv_px.yx);
}

struct scrollcal_vdata {
    int prev_day_header;
    int background_y;
    int4 colorindexes;
};

struct scrollcal_main_coords {
    float2 viewport_px;
    float2 scroll_view_px;
    float2 scroll_abs_px;
    float2 background_px;
};

struct scrollcal_main_coords scrollcal_main_getcoords(struct scrollcal_context ctx, float2 uv_px) {
    int bgh = ctx.other_tex_params.y;

    struct scrollcal_main_coords coords;
    coords.viewport_px = uv_px;

    coords.scroll_abs_px = coords.viewport_px;
    coords.scroll_abs_px -= ctx.borders.zx;
    coords.scroll_view_px = coords.scroll_abs_px;

    coords.scroll_abs_px.y += ctx.scroll_tex_params.x;

    coords.background_px.x = coords.viewport_px.x;
    coords.background_px.y = (coords.scroll_abs_px.y % bgh) + ctx.other_tex_params.x;

    return coords;
}

float3 scrollcal_text_px(struct scrollcal_context ctx, float2 scroll_abs_px) {
    float2 scroll_tex_px = scroll_abs_px;
    float tex_height_div3 = ctx.scroll_tex_params.z / 3;

    float section = floor(scroll_tex_px.y / tex_height_div3);
    
    scroll_tex_px.y = scroll_tex_px.y % tex_height_div3;
    scroll_tex_px.y += ctx.scroll_tex_params.y;

    return float3(scroll_tex_px, section);
}

fixed4 scrollcal_text_colormask(float section) {
    if (section < 1) {
        return fixed4(0,0,1,0);
    } else if (section < 2) {
        return fixed4(0,1,0,0);
    } else if (section < 3) {
        return fixed4(1,0,0,0);
    } else {
        // Overflow
        return fixed4(0,0,0,0);
    }
}

int scrollcal_load_vdata(struct scrollcal_context ctx, float2 abs_px) {
    int v = max(0, floor(abs_px.y + 0));
    
    int vdata_len = ctx.other_tex_params.w;
    int base_offset = SCROLLCAL_DSOFF_PREVDH + vdata_len;

    float2 uv_colors = scrollcal_index_to_uv(ctx.data_width, base_offset + v);
    
    fixed4 rgb_colors = _MainTex.SampleLevel(SCROLLCAL_SAMPLER_POINT, uv_colors, 0);

    struct scrollcal_vdata vdata;
    vdata.prev_day_header = 0;

    return scrollcal_decode_rgb(rgb_colors);
}

int4 scrollcal_decode_colorindexes(int colors) {
    return int4(
        (colors >> 9) & 0x07,
        (colors >> 6) & 0x07,
        (colors >> 3) & 0x07,
        colors & 0x07
    );
}

float4 scrollcal_day_header_template(struct scrollcal_context ctx, float2 offset) {
    int corner_size = ctx.other_tex_params.z;
    int height = ctx.day_header_params.x;
    int albedo_x = ctx.day_header_params.y;
    int alpha_x = ctx.day_header_params.z;
    int tex_y_offset = ctx.day_header_params.w;

    int width = dot(float3(1,-1,-1), float3(ctx.viewport_size.z, ctx.borders.zw));

    float2 uv_px = float2(0, offset.y);

    if (offset.x < corner_size) {
        uv_px.x = offset.x;
    } else if (offset.x < width - corner_size) {
        uv_px.x = corner_size;
    } else {
        uv_px.x = offset.x - width + corner_size * 2;
    }

    uv_px.y -= 1; // XXX: Is this needed?

    return float4(uv_px, uv_px) + float4(albedo_x, tex_y_offset, alpha_x, tex_y_offset);
}

struct scrollcal_render_plan scrollcal_plan_main(struct scrollcal_context ctx, float2 uv_px) {
    int top_day_header = ctx.border_tex_params.w;
    int corner_size = ctx.other_tex_params.z;
    int day_header_height = ctx.day_header_params.x;

    struct scrollcal_main_coords coords = scrollcal_main_getcoords(ctx, uv_px);
    int vdata = scrollcal_load_vdata(ctx, coords.scroll_abs_px);
    int int_header_y = vdata & ~SCROLLCAL_IS_DAY_HEADER;

    struct scrollcal_render_plan plan;

    int col_index;
    if (coords.viewport_px.x < ctx.column_offsets[0]) col_index = 0;
    else if (coords.viewport_px.x < ctx.column_offsets[1]) col_index = 1;
    else if (coords.viewport_px.x < ctx.column_offsets[2]) col_index = 2;
    else col_index = 3;

    int pal_index = scrollcal_decode_colorindexes(vdata)[col_index];

    plan.background_uv = scrollcal_px_to_uv(ctx, coords.background_px);
    plan.overlay_uv = float2(-1, -1);
    plan.overlay_alpha_uv = float2(-1, -1);
    plan.overlay_above_text = false;
    plan.overlay_alpha_mul = 0;

    float3 textuv = scrollcal_text_px(ctx, coords.scroll_abs_px);

    if (coords.scroll_view_px.y <= corner_size) {
        plan.background_uv = scrollcal_px_to_uv(ctx, float2(coords.viewport_px.x, coords.viewport_px.y + scrollcal_load_int(ctx.data_width, SCROLLCAL_DSOFF_HEADER_TEX_Y)));
        plan.colormask = fixed4(0,0,0,0);
        textuv = float3(-1, -1, 0);
    }

    if (coords.scroll_view_px.y <= day_header_height) {
        // This area overlaps the top header. But does it overlap also a second header?

        float4 top_header_coords = scrollcal_day_header_template(ctx, coords.scroll_view_px);
        float3 top_textuv = scrollcal_text_px(ctx, coords.scroll_view_px + float2(0, top_day_header));
        //top_header_text_coords.y += top_day_header;

        pal_index = 0;

        float2 top_coord = float2(0,0);

        if (vdata & SCROLLCAL_IS_DAY_HEADER && coords.scroll_abs_px.y >= top_day_header + day_header_height) {
            int corner_size = ctx.other_tex_params.z;

            // Yep. Decide what we want to do based on whether we need alpha blend the borders.
            pal_index = 0;

            float4 overlap_header_coords = scrollcal_day_header_template(ctx, float2(coords.scroll_abs_px.x, int_header_y + frac(coords.scroll_abs_px.y)));
            plan.overlay_uv = overlap_header_coords.xy;
            plan.overlay_alpha_uv = overlap_header_coords.zw;
            if (int_header_y <= corner_size) {
                // Alpha overlap with base header
                plan.background_uv = scrollcal_px_to_uv(ctx, top_header_coords.xy);
                textuv = top_textuv;
                plan.overlay_above_text = true;
            }
        } else {
            // This is just the top header only
            plan.overlay_uv = top_header_coords.xy;
            plan.overlay_alpha_uv = top_header_coords.zw;
            textuv = top_textuv;

            top_coord = uv_px;
        }

        // Note: We cannot put this in the above else block, or unity's shader compiler will crash with an internal error.
        if (top_coord.x >= ctx.borders.z && top_coord.x <= ctx.viewport_size.z - ctx.borders.w && uv_px.y <= ctx.borders.x + corner_size) {
            plan.background_uv = scrollcal_px_to_uv(ctx, uv_px + float2(0, ctx.border_tex_params.x + ctx.split_params.w));
        }
    } else if (vdata & SCROLLCAL_IS_DAY_HEADER) {
        pal_index = 0;
        int int_header_y = vdata & ~SCROLLCAL_IS_DAY_HEADER;

        float4 overlap_header_coords = scrollcal_day_header_template(ctx, float2(coords.scroll_abs_px.x, int_header_y + frac(coords.scroll_abs_px.y)));
        plan.overlay_uv = overlap_header_coords.xy;
        plan.overlay_alpha_uv = overlap_header_coords.zw;
    }

    if (plan.overlay_uv.x >= 0) {
        float4 borders = 
            float4(0,0,ctx.day_header_params.ww) + float4(0, ctx.viewport_size.x - (ctx.borders.z + ctx.borders.w), 0, day_header_height);
        float4 side_dist = abs(float4(coords.scroll_abs_px.xx, plan.overlay_uv.yy) - borders);

        plan.overlay_uv = scrollcal_px_to_uv(ctx, plan.overlay_uv);
        plan.overlay_alpha_uv = scrollcal_px_to_uv(ctx, plan.overlay_alpha_uv);
        
        // Blend borders

        //float min_dist = min(min(side_dist.x, side_dist.y), min(side_dist.z, side_dist.w));
        float min_dist = min(min(side_dist.x, side_dist.y), min(side_dist.z, side_dist.w));

        plan.overlay_alpha_mul = smoothstep(0, SCROLLCAL_DAY_HEADER_BLEND, min_dist);
    }

    plan.text_uv = scrollcal_px_to_uv(ctx, textuv.xy);
    plan.colormask = scrollcal_text_colormask(textuv.z);
    plan.palette_uv = scrollcal_index_to_uv(ctx.data_width, SCROLLCAL_DSOFF_PALETTE + pal_index);

    return plan;
}

fixed4 scrollcal_sample_plan(struct scrollcal_context ctx, struct scrollcal_render_plan plan, float2 uv_px) {
    // XXX: Why 1.5???
    float2 base_uv = uv_px / 1.5;
    float2 dx_uv = ddx(base_uv);
    float2 dy_uv = ddy(base_uv);

    //float mip = 0.5 * log2(min(sqr_del_max, sqr_del_min * 900));
    float mip = 0.5 * log2(max(dot(dx_uv, dx_uv), dot(dy_uv, dy_uv)));
    mip = min(mip, 3);

    float lod_clamp = 2;

    fixed4 bg = _MainTex.SampleLevel(SCROLLCAL_SAMPLER_TEX, plan.background_uv, mip);
    fixed4 overlay = fixed4(0,0,0,0);
    fixed4 text = fixed4(0,0,0,0);
    fixed overlay_alpha = 1;
    fixed4 text_color = fixed4(0,0,0,0);
    
    if (plan.text_uv.x >= 0) {
        text = _MainTex.SampleLevel(SCROLLCAL_SAMPLER_TEX, plan.text_uv, mip);
        text_color = _MainTex.SampleLevel(SCROLLCAL_SAMPLER_POINT, plan.palette_uv, 0);
    }

    if (plan.overlay_uv.x >= 0) {
        overlay = _MainTex.SampleLevel(SCROLLCAL_SAMPLER_TEX, plan.overlay_uv, mip);
        if (plan.overlay_alpha_uv.x >= 0.0) {
            overlay_alpha = saturate(LinearToGammaSpace(_MainTex.SampleLevel(SCROLLCAL_SAMPLER_TEX, plan.overlay_alpha_uv, mip)).r);
        }
    }

    float text_alpha = saturate(LinearToGammaSpace(dot(text, plan.colormask)));

    overlay_alpha *= plan.overlay_alpha_mul;

    if (plan.overlay_above_text) {
        return lerp(lerp(bg, text_color, text_alpha), overlay, overlay_alpha);
    } else {
        return lerp(lerp(bg, overlay, overlay_alpha), text_color, text_alpha);
    }
}

fixed4 scrollcal_albedo(struct scrollcal_context ctx) {
    float2 uv_px = ctx.viewport_size.xy;
    float cutoff_header_sides = ctx.borders.x + ctx.other_tex_params.z;

    struct scrollcal_render_plan plan;

    if (uv_px.y <= ctx.borders.x) {
        plan = scrollcal_plan_header(ctx, uv_px);
    } else if (ctx.viewport_size.w - uv_px.y <= ctx.borders.y) {
        plan = scrollcal_plan_footer(ctx, uv_px);
    } else if (ctx.borders.z >= uv_px.x) {
        plan = scrollcal_plan_side(ctx, uv_px, 0);
    } else if (uv_px.x >= ctx.viewport_size.z - ctx.borders.w) {
        plan = scrollcal_plan_side(ctx, uv_px - float2(ctx.viewport_size.z - ctx.borders.w, 0), 1);
    } else {
        plan = scrollcal_plan_main(ctx, uv_px);
    }

    return scrollcal_sample_plan(ctx, plan, uv_px);
}
