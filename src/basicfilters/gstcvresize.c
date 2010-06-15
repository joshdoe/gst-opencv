/*
 * GStreamer
 * Copyright (C) 2010 Thiago Santos <thiago.sousa.santos@collabora.co.uk>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Alternatively, the contents of this file may be used under the
 * GNU Lesser General Public License Version 2.1 (the "LGPL"), in
 * which case the following provisions apply instead of the ones
 * mentioned above:
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gst/gst.h>
#include <gst/video/video.h>

#include "gstopencvutils.h"
#include "gstcvresize.h"

GST_DEBUG_CATEGORY_STATIC (gst_cv_resize_debug);
#define GST_CAT_DEFAULT gst_cv_resize_debug

/* Filter signals and args */
enum
{
  /* FILL ME */
  LAST_SIGNAL
};
enum
{
  PROP_0,
  PROP_INTERP_METHOD
};

#define GST_TYPE_CV_RESIZE_INTERP_METHOD (gst_cv_resize_interp_method_get_type ())
static GType
gst_cv_resize_interp_method_get_type (void)
{
  static GType cv_resize_interp_method_type = 0;

  static const GEnumValue interp_methods[] = {
    /*    {CV_BLUR_NO_SCALE, "CV Blur No Scale", "blur-no-scale"}, */
    {CV_INTER_NN, "nearest-neigbor interpolation", "nearest"},
    {CV_INTER_LINEAR, "bilinear interpolation (used by default)", "bilinear"},
    {CV_INTER_AREA, "resampling using pixel area relation (moire free)", "area"},
    {CV_INTER_CUBIC, "bicubic interpolation", "bicubic"},
    {0, NULL, NULL},
  };

  if (!cv_resize_interp_method_type) {
    cv_resize_interp_method_type =
      g_enum_register_static ("GstCvResizeInterpMethodType", interp_methods);
  }
  return cv_resize_interp_method_type;
}

#define DEFAULT_INTERP_METHOD CV_INTER_LINEAR

GST_BOILERPLATE (GstCvResize, gst_cv_resize, GstOpencvBaseTransform,
    GST_TYPE_OPENCV_BASE_TRANSFORM);

static void gst_cv_resize_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec);
static void gst_cv_resize_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec);

static GstCaps *gst_cv_resize_transform_caps (GstBaseTransform * trans,
    GstPadDirection dir, GstCaps * caps);

static GstFlowReturn gst_cv_resize_transform (GstOpencvBaseTransform * filter,
    GstBuffer * buf, IplImage * img, GstBuffer * outbuf, IplImage * outimg);

/* Clean up */
static void
gst_cv_resize_finalize (GObject * obj)
{
  G_OBJECT_CLASS (parent_class)->finalize (obj);
}

/* GObject vmethod implementations */

static void
gst_cv_resize_base_init (gpointer gclass)
{
  GstElementClass *element_class = GST_ELEMENT_CLASS (gclass);
  GstCaps *caps;
  GstPadTemplate *templ;

  /* add sink and source pad templates */
  caps = gst_opencv_caps_from_cv_image_type (CV_8UC1);
  gst_caps_append (caps, gst_opencv_caps_from_cv_image_type (CV_8UC3));
  gst_caps_append (caps, gst_opencv_caps_from_cv_image_type (CV_8UC4));
  gst_caps_append (caps, gst_opencv_caps_from_cv_image_type (CV_16UC1));
  templ = gst_pad_template_new ("sink", GST_PAD_SINK, GST_PAD_ALWAYS,
    gst_caps_ref (caps));
  gst_element_class_add_pad_template (element_class, templ);
  templ = gst_pad_template_new ("src", GST_PAD_SRC, GST_PAD_ALWAYS, caps);
  gst_element_class_add_pad_template (element_class, templ);

  gst_element_class_set_details_simple (element_class,
      "cvresize",
      "Transform/Effect/Video",
      "Applies cvResize OpenCV function to the image",
      "Thiago Santos<thiago.sousa.santos@collabora.co.uk>");
}

/* initialize the cvresize's class */
static void
gst_cv_resize_class_init (GstCvResizeClass * klass)
{
  GObjectClass *gobject_class;
  GstBaseTransformClass *gstbasetransform_class;
  GstOpencvBaseTransformClass *gstopencvbasefilter_class;
  GstElementClass *gstelement_class;

  gobject_class = (GObjectClass *) klass;
  gstelement_class = (GstElementClass *) klass;
  gstbasetransform_class = (GstBaseTransformClass *) klass;
  gstopencvbasefilter_class = (GstOpencvBaseTransformClass *) klass;

  parent_class = g_type_class_peek_parent (klass);

  gobject_class->finalize = GST_DEBUG_FUNCPTR (gst_cv_resize_finalize);
  gobject_class->set_property = gst_cv_resize_set_property;
  gobject_class->get_property = gst_cv_resize_get_property;

  gstbasetransform_class->transform_caps = gst_cv_resize_transform_caps;

  gstopencvbasefilter_class->cv_trans_func = gst_cv_resize_transform;

  g_object_class_install_property (gobject_class, PROP_INTERP_METHOD,
      g_param_spec_enum ("interp-method",
          "interp-method",
          "Interpolation Method",
          GST_TYPE_CV_RESIZE_INTERP_METHOD,
          DEFAULT_INTERP_METHOD, G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS)
      );
}

static void
gst_cv_resize_init (GstCvResize * filter, GstCvResizeClass * gclass)
{
  filter->interp_method = DEFAULT_INTERP_METHOD;

  gst_base_transform_set_in_place (GST_BASE_TRANSFORM (filter), FALSE);
}

static GstCaps *
gst_cv_resize_transform_caps (GstBaseTransform * trans, GstPadDirection dir,
    GstCaps * caps)
{
  GstCaps *ret = NULL;
  GstStructure *structure;

  ret = gst_caps_copy (caps);
  structure = gst_structure_copy (gst_caps_get_structure (ret, 0));

  gst_structure_set (structure,
    "width", GST_TYPE_INT_RANGE, 1, G_MAXINT,
    "height", GST_TYPE_INT_RANGE, 1, G_MAXINT, NULL);

  /* if pixel aspect ratio, make a range of it */
  if (gst_structure_has_field (structure, "pixel-aspect-ratio")) {
    gst_structure_set (structure,
      "pixel-aspect-ratio", GST_TYPE_FRACTION_RANGE, 1, G_MAXINT, G_MAXINT, 1,
      NULL);
  }
  gst_caps_merge_structure (ret, gst_structure_copy (structure));
  gst_structure_free (structure);

  return ret;
}

static void
gst_cv_resize_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec)
{
  GstCvResize *filter = GST_CV_RESIZE (object);

  switch (prop_id) {
    case PROP_INTERP_METHOD:
      filter->interp_method = g_value_get_enum (value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static void
gst_cv_resize_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec)
{
  GstCvResize *filter = GST_CV_RESIZE (object);

  switch (prop_id) {
    case PROP_INTERP_METHOD:
      g_value_set_enum (value, filter->interp_method);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static GstFlowReturn
gst_cv_resize_transform (GstOpencvBaseTransform * base, GstBuffer * buf,
    IplImage * img, GstBuffer * outbuf, IplImage * outimg)
{
  GstCvResize *filter = GST_CV_RESIZE (base);

  cvResize (img, outimg, filter->interp_method);

  return GST_FLOW_OK;
}

gboolean
gst_cv_resize_plugin_init (GstPlugin * plugin)
{
  GST_DEBUG_CATEGORY_INIT (gst_cv_resize_debug, "cvresize", 0, "cvresize");

  return gst_element_register (plugin, "cvresize", GST_RANK_NONE,
      GST_TYPE_CV_RESIZE);
}
