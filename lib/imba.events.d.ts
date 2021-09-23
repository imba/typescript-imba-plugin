declare class EventModifiers {
    /**
     Tells the browser that the default action should not be taken. The event will still continue to propagate up the tree. See Event.preventDefault()
    @see https://imba.io/events/event-modifiers#core-prevent
    */
    prevent(): EventModifiers;
    /**
     Stops the event from propagating up the tree. Event listeners for the same event on nodes further up the tree will not be triggered. See Event.stopPropagation()
    */
    stop(): EventModifiers;
    /**
     * Indicates that the listeners should be invoked at most once. The listener will automatically be removed when invoked.
     */
    once(): EventModifiers;

    capture(): EventModifiers;

    passive(): EventModifiers;

    silence(): EventModifiers;
    silent(): EventModifiers;
    /** The wait modifier delays the execution of subsequent modifiers and callback. It defaults to wait for 250ms, which can be overridden by passing a number or time as the first/only argument. 
     * @detail (time = 500ms)
     */
    wait(time?: Time): EventModifiers;

    /**
     * Hello there
     * @detail (time = 500ms)
     */
    throttle(time?: Time): EventModifiers;

    /**
     * Hello there
     * @detail (time = 500ms)
     */
    debounce(time?: Time): EventModifiers;


    /** 
     * Only trigger handler if event.target is the element itself 
     * 
     */
    self(): EventModifiers;

    /** 
     * Only trigger handler if event.target matches selector
     * @detail (selector)
     * */
    sel(selector: string): EventModifiers;

    /**
     * Only trigger condition is truthy
     * @detail (condition)
     * */
    if(condition: unknown): EventModifiers;

    emit(name: string, data?: any): EventModifiers;
    emitΞname(data?: any): EventModifiers;

    flag(name: string): EventModifiers;
    flagΞname(): EventModifiers;

    /**
     * Logs to console
     * @detail (...data)
     */
    log(...data: any[]): EventModifiers;
}

declare class UIEventModifiers extends EventModifiers {

    /**
    * Only if ctrl key is pressed 
    *
    */
    ctrl(): EventModifiers;

    /**
    * Only if alt key is pressed 
    *
    */
    alt(): EventModifiers;

    /**
    * Only if shift key is pressed 
    *
    */
    shift(): EventModifiers;

    /**
    * Only if meta key is pressed 
    *
    */
    meta(): EventModifiers;

}

declare class MouseEventModifiers extends UIEventModifiers {

}

declare class KeyboardEventModifiers extends UIEventModifiers {
    /**
    * Only if enter key is pressed 
    *
    */
    enter(): EventModifiers;

    /**
    * Only if left key is pressed 
    *
    */
    left(): EventModifiers;

    /**
    * Only if right key is pressed 
    *
    */
    right(): EventModifiers;

    /**
    * Only if up key is pressed 
    *
    */
    up(): EventModifiers;

    /**
    * Only if down key is pressed 
    *
    */
    down(): EventModifiers;

    /**
    * Only if tab key is pressed 
    *
    */
    tab(): EventModifiers;

    /**
    * Only if esc key is pressed 
    *
    */
    esc(): EventModifiers;

    /**
    * Only if space key is pressed 
    *
    */
    space(): EventModifiers;

    /**
    * Only if del key is pressed 
    *
    */
    del(): EventModifiers;
}

declare class PointerEventModifiers extends UIEventModifiers {
    /**
    * Only mouse 
    *
    */
    mouse(): EventModifiers;

    /**
    * Only pen 
    *
    */
    pen(): EventModifiers;

    /**
    * Only hand/fingers 
    *
    */
    touch(): EventModifiers;
}

type ModifierElementTarget = Element | string;

declare class PointerGestureModifiers extends PointerEventModifiers {
    /**
    * Only when touch has moved more than threshold
    * @detail (threshold = 4px)
    */
    moved(threshold?: Length): EventModifiers;


    /**
    * Only when touch has moved left or right more than threshold
    * @detail (threshold = 4px)
    */
    movedΞx(threshold?: Length): EventModifiers;

    /**
    * Only when touch has moved up or down more than threshold
    * @detail (threshold = 4px)
    */
    movedΞy(threshold?: Length): EventModifiers;

    /**
    * Only when touch has moved up more than threshold
    * @detail (threshold = 4px)
    */
    movedΞup(threshold?: Length): EventModifiers;

    /**
    * Only when touch has moved down more than threshold
    * @detail (threshold = 4px)
    */
    movedΞdown(threshold?: Length): EventModifiers;

    /**
     * A convenient touch modifier that takes care of updating the x,y values of some data during touch. When touch starts sync will remember the initial x,y values and only add/subtract based on movement of the touch.
     * 
     * @see https://imba.io/events/touch-events#modifiers-sync
     * @detail (data, xProp?, yProp?)
     */
    sync(data: object, xName?: string | null, yName?: string | null): EventModifiers;

    /**
    * Convert the coordinates of the touch to some other frame of reference.
    * @detail (target?,snap?)
    */
    fit(): EventModifiers;
    fit(start: Length, end: Length, snap?: number): EventModifiers;
    fit(target: ModifierElementTarget): EventModifiers;
    fit(target: ModifierElementTarget, snap?: number): EventModifiers;
    fit(target: ModifierElementTarget, snap?: number): EventModifiers;
    fit(target: ModifierElementTarget, start: Length, end: Length, snap?: number): EventModifiers;

    /**
    * Just like @touch.fit but without clamping x,y to the bounds of the
    * target.
    * @detail (target?, ax?, ay?)
    */
    reframe(): EventModifiers;
    reframe(start: Length, end: Length, snap?: number): EventModifiers;
    reframe(context: Element | string, snap?: number): EventModifiers;
    reframe(context: Element | string, start: Length, end: Length, snap?: number): EventModifiers;

    /**
     * Alias for reframe
     * @deprecated Use `.reframe` instead!
     */
    in(): EventModifiers;
    in(start: Length, end: Length, snap?: number): EventModifiers;
    in(context: Element | string, snap?: number): EventModifiers;
    in(context: Element | string, start: Length, end: Length, snap?: number): EventModifiers;

    /**
    * Allow pinning the touch to a certain point in an element, so that
    * all future x,y values are relative to this pinned point.
    * @detail (target?, ax?, ay?)
    */
    pin(): EventModifiers;
    pin(target: ModifierElementTarget): EventModifiers;
    pin(target: ModifierElementTarget, anchorX?: number, anchorY?: number): EventModifiers;

    /**
    * Round the x,y coordinates with an option accuracy
    * @detail (to = 1)
    */
    round(nearest?: number): EventModifiers;
}


type IntersectRoot = Element | Document;

type IntersectOptions = {
    rootMargin?: string;
    root?: IntersectRoot;
    thresholds?: number[];
}

declare class ImbaIntersectEventModifiers extends EventModifiers {
    /**
    * @detail only when intersection increases
    */
    in(): EventModifiers;

    /**
    * @detail only when intersection decreases
    */
    out(): EventModifiers;

    css(): EventModifiers;

    ___setup(root?: IntersectRoot, thresholds?: number): void;
    ___setup(thresholds?: number): void;
    ___setup(rootMargin: string, thresholds?: number): void;
    ___setup(rootMargin: string, thresholds?: number): void;
    ___setup(options: IntersectOptions): void;
}

declare class ImbaResizeEventModifiers extends UIEventModifiers {
    /*
    in(): EventModifiers;
    out(): EventModifiers;
    css(): EventModifiers;
    */
}

declare class ImbaHotkeyEventModifiers extends UIEventModifiers {
    
    /**
     * 
     * @param pattern string following pattern from mousetrap
     * @see https://craig.is/killing/mice 
     */
    ___setup(pattern:string): void;
    
    /**
    * Also trigger when input,textarea or a contenteditable is focused
    */
    capture(): EventModifiers;

    /**
    * Trigger even if outside of the originating hotkey group
    */
    global(): EventModifiers;
    
    /**
    * Allow subsequent hotkey handlers for the same combo
    * and don't automatically prevent default behaviour of originating
    * keyboard event
    */
    passive(): EventModifiers;
}



interface Event {
    MODIFIERS: EventModifiers;
}

interface UIEvent {
    MODIFIERS: UIEventModifiers;
}

interface MouseEvent {
    MODIFIERS: MouseEventModifiers;
}

interface KeyboardEvent {
    MODIFIERS: KeyboardEventModifiers;
}

interface PointerEvent {
    MODIFIERS: PointerEventModifiers;
}

interface ResizeEvent {
    MODIFIERS: ImbaResizeEventModifiers;
}

declare class PointerGesture extends PointerEvent {
    MODIFIERS: PointerGestureModifiers;
}

declare class ImbaIntersectEvent extends Event {
    /**
    * The raw IntersectionObserverEntry 
    *
    */
    entry: IntersectionObserverEntry;
    /**
    * Ratio of the intersectionRect to the boundingClientRect 
    *
    */
    ratio: number;
    /**
    * Difference in ratio since previous event 
    *
    */
    delta: number;

    MODIFIERS: ImbaIntersectEventModifiers;
}

declare class ImbaResizeEvent extends UIEvent {
    MODIFIERS: ImbaResizeEventModifiers;
}

declare class ImbaSelectionEvent extends Event {

}

declare class ImbaHotkeyEvent extends UIEvent {
    MODIFIERS: ImbaHotkeyEventModifiers;
}


interface GlobalEventHandlersEventMap {
    "touch": PointerGesture;
    "intersect": ImbaIntersectEvent;
    "hotkey": ImbaHotkeyEvent;
    "__unknown": CustomEvent;
}

interface ImbaEvents {
    /**
    * The loading of a resource has been aborted. 
    *
    */
    abort: UIEvent;
    animationcancel: AnimationEvent;
    /**
    * A CSS animation has completed. 
    *
    */
    animationend: AnimationEvent;
    /**
    * A CSS animation is repeated. 
    *
    */
    animationiteration: AnimationEvent;
    /**
    * A CSS animation has started. 
    *
    */
    animationstart: AnimationEvent;

    auxclick: MouseEvent;
    /**
    * An element has lost focus (does not bubble). 
    *
    */
    blur: FocusEvent;

    cancel: Event;
    /**
    * The user agent can play the media, but estimates that not enough data has been loaded to play the media up to its end without having to stop for further buffering of content. 
    *
    */
    canplay: Event;
    /**
    * The user agent can play the media up to its end without having to stop for further buffering of content. 
    *
    */
    canplaythrough: Event;
    /**
    * The change event is fired for <input>, <select>, and <textarea> elements when a change to the element's value is committed by the user. 
    *
    */
    change: Event;
    /**
    * A pointing device button has been pressed and released on an element. 
    *
    */
    click: MouseEvent;
    close: Event;
    contextmenu: MouseEvent;
    cuechange: Event;
    dblclick: MouseEvent;
    drag: DragEvent;
    dragend: DragEvent;
    dragenter: DragEvent;
    dragexit: Event;
    dragleave: DragEvent;
    dragover: DragEvent;
    dragstart: DragEvent;
    drop: DragEvent;
    durationchange: Event;
    emptied: Event;
    ended: Event;
    error: ErrorEvent;
    focus: FocusEvent;
    focusin: FocusEvent;
    focusout: FocusEvent;
    gotpointercapture: PointerEvent;
    input: Event;
    invalid: Event;
    intersect: ImbaIntersectEvent;
    keydown: KeyboardEvent;
    keypress: KeyboardEvent;
    keyup: KeyboardEvent;
    load: Event;
    loadeddata: Event;
    loadedmetadata: Event;
    loadstart: Event;
    lostpointercapture: PointerEvent;
    mousedown: MouseEvent;
    mouseenter: MouseEvent;
    mouseleave: MouseEvent;
    mousemove: MouseEvent;
    mouseout: MouseEvent;
    mouseover: MouseEvent;
    mouseup: MouseEvent;
    pause: Event;
    play: Event;
    playing: Event;
    pointercancel: PointerEvent;
    pointerdown: PointerEvent;
    pointerenter: PointerEvent;
    pointerleave: PointerEvent;
    pointermove: PointerEvent;
    pointerout: PointerEvent;
    pointerover: PointerEvent;
    pointerup: PointerEvent;
    progress: ProgressEvent;
    ratechange: Event;
    reset: Event;
    resize: UIEvent;
    scroll: Event;
    securitypolicyviolation: SecurityPolicyViolationEvent;
    seeked: Event;
    seeking: Event;
    select: Event;
    selectionchange: Event;
    selectstart: Event;
    stalled: Event;
    submit: Event;
    suspend: Event;
    timeupdate: Event;
    toggle: Event;
    touch: PointerGesture;
    hotkey: ImbaHotkeyEvent;
    touchcancel: TouchEvent;
    touchend: TouchEvent;
    touchmove: TouchEvent;
    touchstart: TouchEvent;
    transitioncancel: TransitionEvent;
    transitionend: TransitionEvent;
    transitionrun: TransitionEvent;
    transitionstart: TransitionEvent;
    volumechange: Event;
    waiting: Event;
    wheel: WheelEvent;
    [event: string]: Event;
}