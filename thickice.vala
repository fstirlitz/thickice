/*
 * ThickIce theming engine, a port of ThinIce
 * by: felix <m.p.isaev@yandex.com>
 * released under GNU Lesser GPL version 2.1 (or later)
 */
public class ThickIce: Gtk.ThemingEngine {
	public enum MarkType {
		NONE, SLASH, INVSLASH, DOT, INVDOT, ARROW
	}

	private static Gdk.RGBA lighter(Gdk.RGBA color) {
		return { color.red * 1.8, color.green * 1.8, color.blue * 1.8, color.alpha };
	}

	private static Gdk.RGBA darker(Gdk.RGBA color) {
		return { color.red * 0.6, color.green * 0.6, color.blue * 0.6, color.alpha };
	}

	private static void draw_dot(Cairo.Context cr, Gdk.RGBA c1, Gdk.RGBA c2, double x, double y) {
		Gdk.cairo_set_source_rgba(cr, c1);
        cr.rectangle(x + 1, y + 1, 1, 1);
        cr.rectangle(x + 1, y    , 1, 1);
        cr.rectangle(x    , y + 1, 1, 1);
        cr.fill();

		Gdk.cairo_set_source_rgba(cr, c2);
        cr.rectangle(x - 1, y - 1, 1, 1);
        cr.rectangle(x - 1, y    , 1, 1);
        cr.rectangle(x    , y - 1, 1, 1);
        cr.fill();
	}

	private static void draw_line(Cairo.Context cr, double x0, double y0, double x1, double y1, Gdk.RGBA color, double w, Gtk.BorderStyle style, bool invert, bool flipr = false) {
		if (style == Gtk.BorderStyle.NONE)
			return;
		if (invert) {
			if (style == Gtk.BorderStyle.INSET)
				style = Gtk.BorderStyle.OUTSET;
			else if (style == Gtk.BorderStyle.OUTSET)
				style = Gtk.BorderStyle.INSET;
			else if (style == Gtk.BorderStyle.GROOVE)
				style = Gtk.BorderStyle.RIDGE;
			else if (style == Gtk.BorderStyle.RIDGE)
				style = Gtk.BorderStyle.GROOVE;
		}
		cr.set_line_width(w);
		if ((style == Gtk.BorderStyle.RIDGE) || (style == Gtk.BorderStyle.GROOVE)) {
			Gdk.RGBA lc = lighter(color), dc = darker(color);
			double
				nx = w * (y1 - y0) / (2 * Math.sqrt((x1 - x0)*(x1 - x0) + (y1 - y0)*(y1 - y0))),
				ny = w * (flipr ? -1 : 1) * (x0 - x1) / (2 * Math.sqrt((x1 - x0)*(x1 - x0) + (y1 - y0)*(y1 - y0)));
			if (style == Gtk.BorderStyle.GROOVE) {
				Gdk.RGBA tmp = dc;
				dc = lc;
				lc = tmp;
			}

			Gdk.cairo_set_source_rgba(cr, dc);
			cr.move_to(x0 - nx, y0 - ny);
			cr.line_to(x1 - nx, y1 - ny);
			cr.stroke();

			Gdk.cairo_set_source_rgba(cr, lc);
			cr.move_to(x0 + nx, y0 + ny);
			cr.line_to(x1 + nx, y1 + ny);
			cr.stroke();

			return;
		} else if (style == Gtk.BorderStyle.OUTSET) {
			color = lighter(color);
		}
		Gdk.cairo_set_source_rgba(cr, color);
		cr.move_to(x0 + 0.5, y0 + 0.5);
		cr.line_to(x1 + 0.5, y1 + 0.5);
		cr.stroke();
	}

	private static void draw_mark(Cairo.Context cr, double cx, double cy, double width, double height, MarkType mark, Gdk.RGBA color, Gtk.Orientation orientation) {
		Gdk.RGBA lcolor = lighter(color);
		Gdk.RGBA dcolor = darker (color);

		switch (mark) {
		case MarkType.INVDOT:
		case MarkType.INVSLASH:
			Gdk.RGBA tmp = lcolor;
			lcolor = dcolor;
			dcolor = tmp;
			break;
		default:
			break;
		}

		switch (mark) {
		case MarkType.NONE:
			break;
        case MarkType.DOT:
        case MarkType.INVDOT:
			double modx = 0, mody = 0;
			if (orientation == Gtk.Orientation.HORIZONTAL) {
				modx = 4;
			} else {
				mody = 4;
			}
			draw_dot(cr, lcolor, dcolor, cx - modx, cy - mody);
			draw_dot(cr, lcolor, dcolor, cx       , cy       );
			draw_dot(cr, lcolor, dcolor, cx + modx, cy + mody);
			break;
        case MarkType.SLASH:
        case MarkType.INVSLASH:
			int ax1 = 0, ay1 = 0;
			double thick = (((orientation == Gtk.Orientation.VERTICAL) ? width - 1 : height - 1) / 2) - 1.5;
			if (orientation == Gtk.Orientation.HORIZONTAL) {
				ax1 = -2;
			} else {
				ay1 = -2;
			}
			draw_line(cr,
				cx - thick + ax1, cy + thick + ay1,
				cx + thick + ax1, cy - thick + ay1,
				color, 1,
				mark ==  MarkType.INVSLASH ? Gtk.BorderStyle.RIDGE : Gtk.BorderStyle.GROOVE,
				false
			);
			if (orientation == Gtk.Orientation.HORIZONTAL) {
				ax1 = 2;
			} else {
				ay1 = 2;
			}
			draw_line(cr,
				cx - thick + ax1, cy + thick + ay1,
				cx + thick + ax1, cy - thick + ay1,
				color, 1,
				mark ==  MarkType.INVSLASH ? Gtk.BorderStyle.RIDGE : Gtk.BorderStyle.GROOVE,
				false
			);
			break;
		default:
			break;
		}
	}

	private static void draw_circular_border (Cairo.Context cr, double cx, double cy, double r, double a0, double a1, Gdk.RGBA color, double w, Gtk.BorderStyle style, bool invert) {
		if (style == Gtk.BorderStyle.NONE)
			return;
		if (invert) {
			if (style == Gtk.BorderStyle.INSET)
				style = Gtk.BorderStyle.OUTSET;
			else if (style == Gtk.BorderStyle.OUTSET)
				style = Gtk.BorderStyle.INSET;
			else if (style == Gtk.BorderStyle.GROOVE)
				style = Gtk.BorderStyle.RIDGE;
			else if (style == Gtk.BorderStyle.RIDGE)
				style = Gtk.BorderStyle.GROOVE;
		}
		cr.set_line_width(w);
		if ((style == Gtk.BorderStyle.RIDGE) || (style == Gtk.BorderStyle.GROOVE)) {
			Gdk.RGBA lc = lighter(color), dc = darker(color);
			if (style == Gtk.BorderStyle.RIDGE) {
				Gdk.RGBA tmp = lc;
				lc = dc;
				dc = tmp;
			}
			Gdk.cairo_set_source_rgba(cr, dc);
			cr.arc(cx, cy, r + w/2, a0 * GLib.Math.PI, (a1 + 0.0125) * GLib.Math.PI);
			cr.stroke();

			Gdk.cairo_set_source_rgba(cr, lc);
			cr.arc(cx, cy, r - w/2, a0 * GLib.Math.PI, (a1 + 0.0125) * GLib.Math.PI);
			cr.stroke();
			return;
		} else if (style == Gtk.BorderStyle.OUTSET) {
			color = lighter(color);
		}
		Gdk.cairo_set_source_rgba(cr, color);
		cr.arc(cx, cy, r + 0.5, a0 * GLib.Math.PI, (a1 + 0.0125) * GLib.Math.PI);
		cr.stroke();
	}

	public override void render_option (Cairo.Context cr, double x, double y, double width, double height) {
		Gtk.BorderStyle
			ts = (Gtk.BorderStyle)this.get_property("border-top-style", this.get_state()).get_enum(),
			ls = (Gtk.BorderStyle)this.get_property("border-left-style", this.get_state()).get_enum(),
			rs = (Gtk.BorderStyle)this.get_property("border-right-style", this.get_state()).get_enum(),
			bs = (Gtk.BorderStyle)this.get_property("border-bottom-style", this.get_state()).get_enum();
		int
			tw = this.get_property("border-top-width", this.get_state()).get_int(),
			lw = this.get_property("border-left-width", this.get_state()).get_int(),
			rw = this.get_property("border-right-width", this.get_state()).get_int(),
			bw = this.get_property("border-bottom-width", this.get_state()).get_int();
		Gdk.RGBA
			tc = *(Gdk.RGBA*)this.get_property("border-top-color", this.get_state()).get_boxed(),
			lc = *(Gdk.RGBA*)this.get_property("border-left-color", this.get_state()).get_boxed(),
			rc = *(Gdk.RGBA*)this.get_property("border-right-color", this.get_state()).get_boxed(),
			bc = *(Gdk.RGBA*)this.get_property("border-bottom-color", this.get_state()).get_boxed(),
			gc = this.get_background_color(this.get_state());

		double cx = x + width / 2, cy = y + height / 2, r = (double.min(width, height) / 2) - 1;

		cr.new_path();
		cr.set_source_rgba(gc.red, gc.green, gc.blue, gc.alpha);
		cr.arc(cx, cy, r, 0, 2 * GLib.Math.PI);
		cr.fill();

		draw_circular_border(cr, cx, cy, r, 1.25, 1.75, tc, tw, ts, false);
		draw_circular_border(cr, cx, cy, r, 1.75, 2.25, rc, rw, rs, true);
		draw_circular_border(cr, cx, cy, r, 2.25, 2.75, bc, bw, bs, true);
		draw_circular_border(cr, cx, cy, r, 2.75, 3.25, lc, lw, ls, false);
	}

	public override void render_check (Cairo.Context cr, double x, double y, double width, double height) {
		render_background(cr, x, y, width, height);

		Gtk.BorderStyle
			ts = (Gtk.BorderStyle)this.get_property("border-top-style", this.get_state()).get_enum(),
			ls = (Gtk.BorderStyle)this.get_property("border-left-style", this.get_state()).get_enum(),
			rs = (Gtk.BorderStyle)this.get_property("border-right-style", this.get_state()).get_enum(),
			bs = (Gtk.BorderStyle)this.get_property("border-bottom-style", this.get_state()).get_enum();
		int
			tw = this.get_property("border-top-width", this.get_state()).get_int(),
			lw = this.get_property("border-left-width", this.get_state()).get_int(),
			rw = this.get_property("border-right-width", this.get_state()).get_int(),
			bw = this.get_property("border-bottom-width", this.get_state()).get_int();
		Gdk.RGBA
			tc = *(Gdk.RGBA*)this.get_property("border-top-color", this.get_state()).get_boxed(),
			lc = *(Gdk.RGBA*)this.get_property("border-left-color", this.get_state()).get_boxed(),
			rc = *(Gdk.RGBA*)this.get_property("border-right-color", this.get_state()).get_boxed(),
			bc = *(Gdk.RGBA*)this.get_property("border-bottom-color", this.get_state()).get_boxed();

		draw_line(cr, x        , y         , x + width, y         , tc, tw, ts, false);
		draw_line(cr, x + width, y         , x + width, y + height, rc, rw, rs, true);
		draw_line(cr, x + width, y + height, x        , y + height, bc, bw, bs, true);
		draw_line(cr, x        , y + height, x        , y         , lc, lw, ls, false);
	}

	public override void render_line (Cairo.Context cr, double x0, double y0, double x1, double y1) {
		Gdk.RGBA color = *(Gdk.RGBA*)this.get_property("color", this.get_state()).get_boxed();

		draw_line(cr, x0, y0, x1, y1, color, 1, Gtk.BorderStyle.GROOVE, true, true);
	}

	public override void render_slider(Cairo.Context cr, double x, double y, double width, double height, Gtk.Orientation orientation) {
		const int SMALLEST_HANDLE = 17;

		Gtk.BorderStyle
			ts = (Gtk.BorderStyle)this.get_property("border-top-style", this.get_state()).get_enum(),
			ls = (Gtk.BorderStyle)this.get_property("border-left-style", this.get_state()).get_enum(),
			rs = (Gtk.BorderStyle)this.get_property("border-right-style", this.get_state()).get_enum(),
			bs = (Gtk.BorderStyle)this.get_property("border-bottom-style", this.get_state()).get_enum();
		int
			tw = this.get_property("border-top-width", this.get_state()).get_int(),
			lw = this.get_property("border-left-width", this.get_state()).get_int(),
			rw = this.get_property("border-right-width", this.get_state()).get_int(),
			bw = this.get_property("border-bottom-width", this.get_state()).get_int();
		Gdk.RGBA
			tc = *(Gdk.RGBA*)this.get_property("border-top-color", this.get_state()).get_boxed(),
			lc = *(Gdk.RGBA*)this.get_property("border-left-color", this.get_state()).get_boxed(),
			rc = *(Gdk.RGBA*)this.get_property("border-right-color", this.get_state()).get_boxed(),
			bc = *(Gdk.RGBA*)this.get_property("border-bottom-color", this.get_state()).get_boxed(),
			mc = *(Gdk.RGBA*)this.get_property("color", this.get_state()).get_boxed();

		bool rect = false;
		MarkType mark = (MarkType)this.get_property("-thickice-mark-type", this.get_state()).get_enum();

		rect = !this.get_property("-thickice-chopoff", this.get_state()).get_boolean();

		if ((width <= SMALLEST_HANDLE) && (height <= SMALLEST_HANDLE)) {
			mark = MarkType.NONE;
			rect = true;
		}

		if (rect) {
			render_background(cr, x, y, width, height);
			draw_mark(cr, x + width / 2, y + height / 2, width, height, mark, mc, orientation);
			render_frame(cr, x, y, width, height);
			return;
		}

		double chopoff;

		if (orientation == Gtk.Orientation.HORIZONTAL) {
			chopoff = (width - SMALLEST_HANDLE).clamp(0, 6);
		} else {
			chopoff = (height - SMALLEST_HANDLE).clamp(0, 6);
		}

		double pts[12] = {
			x                 , y+height-1        , // bottom-left
			x                 , y+chopoff         , // almost-top-left
			x+chopoff         , y                 , // top-almost-left
			x+width-1         , y                 , // top-right
			x+width-1         , y+height-1-chopoff, // almost-bottom-right
			x+width-1-chopoff , y+height-1          // bottom-almost-right
		};

		cr.new_path();
		for (int i = 0; i < 6; ++i)
			cr.line_to(pts[2*i] + 0.5, pts[2*i+1] + 0.5);
		cr.close_path();
		cr.clip();
		render_background(cr, x, y, width, height);
		cr.reset_clip();

		draw_mark(cr, x + width / 2, y + height / 2, width, height, mark, mc, orientation);

		draw_line(cr, pts[ 0], pts[ 1], pts[ 2], pts[ 3], lc, lw, ls, false); // eb/el-at/el
		draw_line(cr, pts[ 2], pts[ 3], pts[ 4], pts[ 5], tc, tw, ts, false); // at/el-et/al
		draw_line(cr, pts[ 4], pts[ 5], pts[ 6], pts[ 7], tc, tw, ts, false); // et/al-et/er
		draw_line(cr, pts[ 6], pts[ 7], pts[ 8], pts[ 9], rc, rw, rs, true ); // et/er-ab/er
		draw_line(cr, pts[ 8], pts[ 9], pts[10], pts[11], rc, rw, rs, true ); // ab/er-eb/ar
		draw_line(cr, pts[10], pts[11], pts[ 0], pts[ 1], bc, bw, bs, true ); // eb/ar-eb/el
	}

	public override void render_handle (Cairo.Context cr, double x, double y, double width, double height) {
		int dots = this.get_property("-thickice-handle-dots", this.get_state()).get_int();
		Gdk.RGBA color = *(Gdk.RGBA*)this.get_property("background-color", this.get_state()).get_boxed();
		Gdk.RGBA lcolor = lighter(color);
		Gdk.RGBA dcolor = darker (color);

		double start_i, end_i, w;
		w = width > height ? width : height;

		if (dots == -1) {
			start_i = 5;
			end_i = w - 5;
		} else {
			start_i = w / 2 - dots * 4;
			end_i = w / 2 + dots * 4;
		}

		if (width > height) {
			for (double i = x + start_i; i < x + end_i; i += 8)
				draw_dot(cr, lcolor, dcolor, i, y + height / 2);
		} else {
			for (double i = y + start_i; i < y + end_i; i += 8)
				draw_dot(cr, lcolor, dcolor, x + width / 2, i);
		}
	}

	public ThickIce() {
		Object(name: "thickice");

		// XXX: GTK 3.8 deprecates this - what gives?
		Gtk.ThemingEngine.register_property("thickice", null,
			(GLib.ParamSpec*)(new GLib.ParamSpecBoolean("chopoff", "", "", false, 0))
		);
		Gtk.ThemingEngine.register_property("thickice", null,
			(GLib.ParamSpec*)(new GLib.ParamSpecInt("handle-dots", "", "", -1, int.MAX, 0, 0))
		);
		Gtk.ThemingEngine.register_property("thickice", null,
			(GLib.ParamSpec*)(new GLib.ParamSpecEnum("mark-type", "", "", typeof(MarkType), (int)MarkType.NONE, 0))
		);
	}
}

[ModuleInit]
public void theme_init (TypeModule module) {
}

public void theme_exit () {
}

public Gtk.ThemingEngine create_engine () {
	return new ThickIce();
}
