﻿using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using Candlechart.Chart;
using Candlechart.Core;
using Candlechart.Theme;

namespace Candlechart.Series
{
    public abstract class Series : IChartItem, IDisposable
    {
        // Fields
        public volatile bool isDisposed;

        private string _name;

        // Methods
        protected Series(string name)
        {
            Name = name;
        }

        // Properties
        public Color BackColor { get; set; }

        protected ChartControl Chart => Owner.Owner;

        internal virtual string CurrentPriceString => string.Empty;

        private Color? foreColor;
        public Color ForeColor
        {
            get { return foreColor ?? Chart.visualSettings.SeriesForeColor; }
            set { foreColor = value; }
        }

        private LineStyle? lineStyle;
        public LineStyle LineStyle
        {
            get { return lineStyle ?? Chart.visualSettings.SeriesLineStyle; }
            set { lineStyle = value; }
        }

        private float? lineWidth;
        public float LineWidth
        {
            get { return lineWidth ?? Chart.visualSettings.SeriesLineWidth; }
            set { lineWidth = value; }
        }

        public string Name
        {
            get { return _name; }
            set
            {
                if (string.IsNullOrEmpty(value))
                {
                    throw new ArgumentNullException("Name", "Name cannot be a null string or empty.");
                }
                _name = value;
            }
        }

        public int NumberDecimalDigits { get; set; } = 2;

        internal Pane Owner { get; set; }

        #region IChartItem Members

        public virtual void Draw(Graphics g, RectangleD worldRect, Rectangle canvasRect)
        {
            if (Chart.visualSettings.SeriesAntiAlias)
                g.SmoothingMode = SmoothingMode.AntiAlias;            
        }

        public abstract bool GetXExtent(ref double left, ref double right);
        public abstract bool GetYExtent(double left, double right, ref double top, ref double bottom);

        #endregion

        public override string ToString()
        {
            return Name;
        }

        public void Dispose()
        {
            isDisposed = true;
        }

        public abstract int DataCount { get; }

        public Pen MakePen(Color color)
        {
            var style = 
                LineStyle == LineStyle.Solid ? DashStyle.Solid
                : LineStyle == LineStyle.Dash ? DashStyle.Dash
                : LineStyle == LineStyle.DashDot ? DashStyle.DashDot
                : LineStyle == LineStyle.Dot ? DashStyle.Dot
                : DashStyle.DashDotDot;
            return new Pen(color, lineWidth ?? 1) { DashStyle = style };
        }
    }
}